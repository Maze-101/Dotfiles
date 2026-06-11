return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        main = "nvim-treesitter",

        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            local ensure_installed = {
                "lua",
                "python",
                "typescript",
                "javascript",
                "rust",
                "tsx",
                "c",
                "cpp",
                "bash",
                "java",
                "html",
                "css",
                "json",
                "graphql",
            }

            local ts_config = require("nvim-treesitter.config")
            local ts_main = require("nvim-treesitter")

            local installed = ts_config.get_installed()
            local to_install = {}
            for _, lang in ipairs(ensure_installed) do
                if not vim.tbl_contains(installed, lang) then
                    table.insert(to_install, lang)
                end
            end

            if #to_install > 0 then
                ts_main.install(to_install)
            end
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "af", mode = { "x", "o" } },
            { "if", mode = { "x", "o" } },
            { "ac", mode = { "x", "o" } },
            { "ic", mode = { "x", "o" } },
            { "as", mode = { "x", "o" } },
        },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    enable = true,
                    lookahead = true,
                },
            })

            local select = require("nvim-treesitter-textobjects.select").select_textobject

            vim.keymap.set({ "x", "o" }, "af", function()
                select("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "if", function()
                select("@function.inner", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ac", function()
                select("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ic", function()
                select("@class.inner", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "as", function()
                select("@local.scope", "locals")
            end)
        end,
    },
}
