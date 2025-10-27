return {
-- 🔠 입력기 자동 영어 전환: im-select + macism
  {
    "keaising/im-select.nvim",
    config = function()
      require("im_select").setup({
        default_im_select = "com.apple.keylayout.ABC",
        default_command = "/opt/homebrew/bin/macism",
      })
    end,
  },

  -- 🧭 포커스 복귀 시 자동 영어 전환
  {
    "nvim-lua/plenary.nvim", -- dummy dep (lazy.nvim requires plugin block)
    config = function()
      vim.api.nvim_create_autocmd("FocusGained", {
        pattern = "*",
        callback = function()
          vim.fn.system("/opt/homebrew/bin/macism com.apple.keylayout.ABC")
        end,
      })
    end,
  },

  -- 💻 터미널 통합
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-`>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },
}
