-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
--

return {
	{
		"abecodes/tabout.nvim",
		lazy = false,
		config = function()
			require("tabout").setup({
				tabkey = "<Tab>",
				backwards_tabkey = "<S-Tab>",
				act_as_tab = true,
				act_as_shift_tab = false,
				default_tab = "<C-t>",
				default_shift_tab = "<C-d>",
				enable_backwards = true,
				completion = false,
				tabouts = {
					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
					{ open = "{", close = "}" },
				},
				ignore_beginning = true,
				exclude = {},
			})
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter",
			"L3MON4D3/LuaSnip",
			"hrsh7th/nvim-cmp",
		},
		opt = true,
		event = "InsertCharPre",
		priority = 1000,
	},
	{
		"L3MON4D3/LuaSnip",
		keys = function()
			return {}
		end,
	},
	"theprimeagen/harpoon",

	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		lazy = true,
	},
}

-- See the kickstart.nvim README for more information
