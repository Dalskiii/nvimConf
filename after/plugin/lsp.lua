local lsp = require("lsp-zero")
local lspconfig = require("lspconfig")
lsp.preset("recommended")

require("mason").setup({ -- setup mason
	ui = { border = "rounded" },
})

require("mason-lspconfig").setup({ -- setup mason-lspconfig
	ensure_installed = {
		"clangd",
		"lua_ls",
		"tsserver",
        "rust_analyzer",
	},
	-- See :help mason-lspconfig.setup_handlers()
	handlers = {
		function(server)
			-- See :help lspconfig-setup
			lspconfig[server].setup({})
		end,
		["tsserver"] = function()
			lspconfig.ts_ls.setup({
				settings = {
					completions = {
						completeFunctionCalls = true,
					},
				},
			})
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


lsp.configure('clangd', {
    settings = {
        clangd = {
            arguments = {
                "-style='{IndentWidth: 4, TabWidth: 4, UseTab: Never}'",
                "-I/usr/include/c++/<13>",
                "-I/usr/include/x86_64-linux-gnu/c++/<13>",
                "-I/usr/lib/gcc/x86_64-linux-gnu/<version>/include",
                "-gcc-toolchain=/usr/bin/gcc"
            }
        }
    }
})
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

--lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
require('lspconfig').clangd.setup {
    cmd = { "clangd", "--clang-tidy" },  -- Enable clang-tidy diagnostics
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_dir = require('lspconfig').util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
    init_options = {
        clangdFileStatus = true,
    },
    settings = {
        clangd = {
            compilationDatabasePath = "build",
            arguments = { "--clang-tidy" },
        }
    },
}

