type Input = {
  agent: string
  description: string
  prompt: string
  model: string
  sessionID: string
  background: boolean
}

export default {
  id: "subagent.schema-fix",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.update("subagent", (tool) => {
        const execute = tool.execute
        tool.input = {
          type: "object",
          properties: {
            agent: { type: "string", description: "Specialized agent to use." },
            description: { type: "string", description: "Short 3-5 word task label." },
            prompt: { type: "string", description: "Complete task instructions." },
            model: { type: "string", description: "Required compatibility field. Use an empty string unless the user explicitly requests a model." },
            sessionID: { type: "string", description: "Required compatibility field. Use an empty string for a new child; use a returned child session ID only to continue it." },
            background: { type: "boolean", description: "Run asynchronously when true." },
          },
          required: ["agent", "description", "prompt", "model", "sessionID", "background"],
          additionalProperties: false,
        }
        tool.execute = (input, context) => {
          const value = input as Input
          return execute({
            ...value,
            model: value.model || undefined,
            sessionID: value.sessionID || undefined,
          }, context)
        }
      })
    })
  },
}
