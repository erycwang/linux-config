return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    config = function()
      vim.cmd("colorscheme tokyonight")
    end,
  },

  { 
    "ellisonleao/gruvbox.nvim", 
    priority = 1000 , 
    config = function()
	vim.cmd("colorscheme gruvbox")
    end, 
    opts = ...,
    },
}
