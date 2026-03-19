return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      enable_on_startup = true,
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
      },
    })
  end,
}
