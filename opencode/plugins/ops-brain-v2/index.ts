import { execFile } from "node:child_process"
import { mkdtemp, open, rm } from "node:fs/promises"
import { homedir, tmpdir } from "node:os"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

type Json = Record<string, unknown>
type SessionState = { repo: string; query: string; injected: boolean }

const PINNED_PYTHON = "/opt/homebrew/bin/python3"
const TIMEOUT_MS = 3000
const PROTOCOL_VERSION = "1.0"

function run(python: string, brain: string, args: string[]): Promise<string> {
  return new Promise((resolve, reject) => {
    execFile(python, [brain, ...args], { timeout: TIMEOUT_MS, maxBuffer: 256 * 1024, env: { ...process.env } }, (error, stdout) => {
      if (error) reject(error)
      else resolve(stdout)
    })
  })
}

function textFromMessages(messages: unknown): string {
  if (!Array.isArray(messages)) return ""
  for (let index = messages.length - 1; index >= 0; index--) {
    const message = messages[index] as Json
    const info = message.info as Json | undefined
    if (message?.role !== "user" && info?.role !== "user") continue
    const parts = Array.isArray(message.parts) ? message.parts : Array.isArray(message.content) ? message.content : []
    const text = parts.map((part) => typeof part === "string" ? part : ((part as Json)?.type === "text" ? String((part as Json).text ?? "") : "")).join(" ").trim()
    if (text) return text
  }
  return ""
}

function substantive(text: string): boolean {
  return text.replace(/\s+/g, " ").trim().length >= 20
}

function clearlyDifferent(left: string, right: string): boolean {
  if (!left) return true
  const words = (value: string) => new Set((value.toLowerCase().match(/[a-z0-9_-]{3,}/g) ?? []).slice(0, 40))
  const a = words(left), b = words(right)
  if (!b.size) return false
  let overlap = 0
  for (const word of b) if (a.has(word)) overlap++
  return overlap / Math.max(1, Math.min(a.size, b.size)) < 0.35
}

async function withRequestFile<T>(payload: Json, callback: (path: string) => Promise<T>): Promise<T> {
  const directory = await mkdtemp(join(tmpdir(), "ops-brain-"))
  const path = join(directory, "request.json")
  try {
    const handle = await open(path, "wx", 0o600)
    await handle.writeFile(JSON.stringify(payload), "utf8")
    await handle.close()
    return await callback(path)
  } finally {
    await rm(directory, { recursive: true, force: true })
  }
}

export default {
  id: "ops-brain.v2",
  async setup(ctx) {
    const adapterDirectory = dirname(fileURLToPath(import.meta.url))
    const ownConfig = join(adapterDirectory, "..", "..", "ops-brain.json")
    let config: Json
    try {
      config = await Bun.file(ownConfig).json()
    } catch {
      return
    }
    const vault = String(process.env.OPS_BRAIN_VAULT || config.vault || "")
    if (!vault) return
    const python = process.env.OPS_BRAIN_PYTHON || PINNED_PYTHON
    const brain = join(vault, "brain.py")
    let settings: Json
    try {
      settings = await Bun.file(join(vault, "config", "settings.json")).json()
    } catch {
      return
    }
    const mode = String(settings.mode || "normal")
    const sessions = new Map<string, SessionState>()
    const listedAgents = await ctx.agent.list().catch(() => [])
    const agentItems = Array.isArray(listedAgents) ? listedAgents : (Array.isArray((listedAgents as Json).data) ? (listedAgents as Json).data as Json[] : [])
    const primaryAgents = new Set(["build", "plan", ...agentItems.filter((agent) => agent.mode !== "subagent").map((agent) => String(agent.id))])

    await ctx.session.hook("context", async (event) => {
      try {
        if (mode === "manual") return
        if (primaryAgents.size && !primaryAgents.has(String(event.agent))) return
        const sessionResult = await ctx.session.get({ sessionID: event.sessionID }) as Json
        const session = (sessionResult.data as Json | undefined) || sessionResult
        if (session.parentID) return
        let query = textFromMessages(event.messages)
        if (!query) {
          const contextResult = await ctx.session.context({ sessionID: event.sessionID }) as unknown
          const contextMessages = Array.isArray(contextResult) ? contextResult : (Array.isArray((contextResult as Json)?.data) ? (contextResult as Json).data : [])
          query = textFromMessages(contextMessages)
        }
        if (!substantive(query)) return
        const repo = String((session.location as Json | undefined)?.directory || ctx.location.directory)
        const previous = sessions.get(event.sessionID)
        const shouldRefresh = !previous || previous.repo !== repo || (mode === "normal" && clearlyDifferent(previous.query, query))
        if (!shouldRefresh) return
        await run(python, brain, ["project-identify", "--repo", repo])
        const maxChars = mode === "economical" ? 2000 : 5000
        const packet = await run(python, brain, ["context", "--repo", repo, "--query", query.slice(0, 1000), "--max-chars", String(maxChars)])
        if (!packet || packet.length > maxChars + 1) return
        event.system.push({ type: "text", text: packet.trimEnd() })
        sessions.set(event.sessionID, { repo, query, injected: true })
      } catch {
        // Fail open: ordinary OpenCode work proceeds with no additional context.
      }
    })

    await ctx.tool.transform((editor) => {
      editor.namespace({ name: "ops_brain", description: "Search and maintain the local durable operations brain." })
      const execute = async (args: string[]) => {
        try { return { content: await run(python, brain, args) } }
        catch { return { content: "ops-brain is unavailable; continue without it." } }
      }
      editor.add({
        name: "search", description: "Search durable notes before creating a new note.", options: { namespace: "ops_brain" },
        input: { type: "object", properties: { query: { type: "string" }, limit: { type: "integer", minimum: 1, maximum: 20 } }, required: ["query"], additionalProperties: false },
        execute: async (input) => execute(["search", String((input as Json).query), "--limit", String((input as Json).limit || 10)]),
      })
      editor.add({
        name: "read", description: "Read one durable note by stable note ID.", options: { namespace: "ops_brain" },
        input: { type: "object", properties: { note_id: { type: "string" } }, required: ["note_id"], additionalProperties: false },
        execute: async (input) => execute(["read", String((input as Json).note_id)]),
      })
      editor.add({
        name: "status", description: "Show local ops-brain health and index status.", options: { namespace: "ops_brain" },
        input: { type: "object", properties: {}, additionalProperties: false }, execute: async () => execute(["status"]),
      })
      const writer = (kind: "remember" | "checkpoint") => async (input: unknown) => {
        const data = input as Json
        const payload = { protocol_version: PROTOCOL_VERSION, receipt_id: String(data.receipt_id), expected_sha256: data.expected_sha256, note: data.note }
        try {
          return await withRequestFile(payload, async (path) => ({ content: await run(python, brain, [kind, "--file", path]) }))
        } catch {
          return { content: "ops-brain write was not saved. Check the request and retry; ordinary work may continue." }
        }
      }
      const noteSchema = {
        type: "object", properties: {
          id: { type: "string" }, title: { type: "string" }, type: { type: "string", enum: ["project", "project-state", "system", "runbook", "incident", "decision", "session", "observation"] },
          status: { type: "string" }, confidence: { type: "string", enum: ["verified", "reported", "inferred", "unknown"] }, sensitivity: { type: "string", enum: ["public", "internal", "restricted"] },
          review_after: { type: "string" }, projects: { type: "array", items: { type: "string" } }, systems: { type: "array", items: { type: "string" } }, tags: { type: "array", items: { type: "string" } }, aliases: { type: "array", items: { type: "string" } }, body: { type: "string" },
        }, required: ["id", "title", "confidence", "body"], additionalProperties: false,
      }
      const writeInput = { type: "object", properties: { receipt_id: { type: "string" }, expected_sha256: { type: "string" }, note: noteSchema }, required: ["receipt_id", "note"], additionalProperties: false }
      editor.add({ name: "remember", description: "Write a concise durable fact or decision after searching. Secret-like content is rejected.", options: { namespace: "ops_brain" }, input: writeInput, execute: writer("remember") })
      editor.add({ name: "checkpoint", description: "Write a concise completed-work checkpoint with checks, decisions, unresolved items, and one next action.", options: { namespace: "ops_brain" }, input: writeInput, execute: writer("checkpoint") })
      editor.add({
        name: "capture", description: "Write one session checkpoint plus reusable topical notes with bidirectional wiki links and metadata. Search first; existing topical notes require expected_sha256.", options: { namespace: "ops_brain" },
        input: { type: "object", properties: { receipt_id: { type: "string" }, checkpoint: noteSchema, learnings: { type: "array", maxItems: 20, items: { type: "object", properties: { ...noteSchema.properties, expected_sha256: { type: "string" } }, required: noteSchema.required, additionalProperties: false } } }, required: ["receipt_id", "checkpoint", "learnings"], additionalProperties: false },
        execute: async (input) => {
          const data = input as Json
          const payload = { protocol_version: PROTOCOL_VERSION, receipt_id: String(data.receipt_id), checkpoint: data.checkpoint, learnings: data.learnings }
          try { return await withRequestFile(payload, async (path) => ({ content: await run(python, brain, ["capture", "--file", path]) })) }
          catch { return { content: "ops-brain capture was not saved. Check IDs and expected_sha256 values, then retry." } }
        },
      })
    })
  },
}
