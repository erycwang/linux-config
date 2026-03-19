require("config.lazy")

vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = vim.fn.expand("~") .. "/Projects/linux-config/hypr/*",
  callback = function()
    vim.opt_local.backupcopy = "no"
  end,
})
