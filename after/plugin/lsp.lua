print("LSP config loaded")
local lsp = require("lsp-zero")
local lspconfig = require("lspconfig")
lsp.preset("recommended")

lsp.set_preferences({
    suggest_lsp_servers = true,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

-- Add the diagnostic configuration for virtual text and error display
require('nvim-autopairs').setup({
    check_ts = true, -- Enable treesitter integration (if you use treesitter)
})
-- Mason setup
require("mason").setup({
    ui = { border = "rounded" },
})

require("mason-lspconfig").setup({
    ensure_installed = {
        "clangd",
        "lua_ls",
        "rust_analyzer",
    },
    -- LSP server handlers
    handlers = {
        function(server)
            lspconfig[server].setup({})
        end,
    },
})

-- Fix Undefined global 'vim'
lsp.configure('lua-language-server', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

-- Clangd configuration
-- Set up nvim-cmp (autocompletion)
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection
    ["<C-Space>"] = cmp.mapping.complete(),             -- Manually trigger completion
    ['<Up>'] = function()
        if cmp.visible() then
            cmp.abort() -- Close the completion menu
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), 'n', true)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), 'n', true)
        end
    end,

    -- Custom behavior for Down key
    ['<Down>'] = function()
        if cmp.visible() then
            cmp.abort() -- Close the completion menu
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), 'n', true)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), 'n', true)
        end
    end,

    -- Custom behavior for Left key
    ['<Left>'] = function()
        if cmp.visible() then
            cmp.abort() -- Close the completion menu
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), 'n', true)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), 'n', true)
        end
    end,

    -- Custom behavior for Right key
    ['<Right>'] = function()
        if cmp.visible() then
            cmp.abort() -- Close the completion menu
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), 'n', true)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), 'n', true)
        end
    end,
})
-- Disable Tab and Shift-Tab behavior in autocompletion (if you don't want them)
-- Apply the nvim-cmp configuration
lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)
-- LSP Preferences

-- Additional clangd setup
-- Remove direct lspconfig setup and move everything to lsp.configure
lsp.configure('clangd', {
    cmd = { "clangd", "--clang-tidy", "--header-insertion=never" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_dir = require('lspconfig').util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
    init_options = {
        clangdFileStatus = true, -- Shows clangd's file processing status
    },
    settings = {
        clangd = {
            arguments = {
                "-I/home/stud/sources/rpi-5.4.83/include", -- Adjust path to include directory
                "-I/home/stud/sources/rpi-5.4.83/arch/arm/include",
                "--clang-tidy"
            },
            compilationDatabasePath = "/home/stud/.config/clangd/config.yaml", -- Path to your compile_commands.json
        }
    },
})

lsp.on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
        -- key mappings for lsp
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "k", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<æ>", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "<ø>", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<c-h>", function() vim.lsp.buf.signature_help() end, opts)
end
-- Then setup nvim-cmp and everything else as usual
lsp.setup()

vim.diagnostic.config({
    virtual_text = {
        prefix = '●', -- You can change this to any symbol you prefer
        spacing = 4, -- Space between the virtual text and the error message
    },
    signs = true, -- Use the icons from your `lsp.set_preferences` in the sign column
    underline = true, -- Underline the line with errors
    severity_sort = true, -- Sort diagnostics by severity
    update_in_insert = true, -- Only show diagnostics after leaving insert mode
})
