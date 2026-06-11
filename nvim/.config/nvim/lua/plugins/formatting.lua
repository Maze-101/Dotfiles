return {
    -- 1. Formatting Plugin
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local conform = require("conform")

            conform.setup({
                formatters_by_ft = {
                    -- Frontend / Web (Prettier handles all of these perfectly)
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    javascriptreact = { "prettier" },
                    typescriptreact = { "prettier" },
                    css = { "prettier" },
                    html = { "prettier" },
                    json = { "prettier" },
                    yaml = { "prettier" },
                    markdown = { "prettier" },
                    graphql = { "prettier" },

                    -- Backend & Systems Languages
                    lua = { "stylua" },
                    python = { "isort", "black" }, -- black for formatting, isort to sort imports
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    bash = { "shfmt" },
                    java = { "google-java-format" },
                },

                -- Format on save configuration
                formatters = {
                    prettier = {
                        args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" },
                    },
                },
                format_on_save = {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                },
            })

            -- Optional: Keymap to manually trigger formatting
            vim.keymap.set({ "n", "v" }, "<leader>pp", function()
                conform.format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                })
            end, { desc = "Format file or range (in visual mode)" })
        end,
    },

    -- 2. Linting Plugin
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
            }

            -- Automatically run linter on text changes, insert leave, and save
            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
