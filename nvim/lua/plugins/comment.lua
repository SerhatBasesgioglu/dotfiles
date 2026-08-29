return{
    "numToStr/Comment.nvim",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        local comment = require("Comment")

        comment.setup({
            mappings = {
                basic = true,
                extra = true,
            },
            pre_hook = function()
                return vim.bo.commentstring
            end,
        })
    end
}
