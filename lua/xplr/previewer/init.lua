-- wrapper around Telescope previewers that provides switching previewer based on file extension of xplr hovered file
local previewers = require("telescope.previewers")
local Popup = require("nui.popup")
local Job = require("plenary.job")
local config = require("xplr.config")

local Previewer = {}
Previewer.__index = Previewer

function Previewer:new(opts)
  return setmetatable({
    ui = Popup(vim.deepcopy(config.previewer.ui or config.xplr.ui)), -- pass xplr opts then change w set_position
    file = previewers.vim_buffer_cat.new({}),
    xplr_winid = opts.xplr_winid,
  }, Previewer)
end

function Previewer:start(opts)
  opts = opts or {}

  local on_output = vim.schedule_wrap(function(_, line, _)
    if not line or line == "" then
      return
    end
    --log.info(line)
    self.file:preview({ path = line }, {
      preview_win = self.ui.winid,
      prompt_win = self.xplr_winid,
    })
  end)

  self.job = Job:new({
    command = "cat",
    args = { opts.fifo_path },
    enable_recording = false,
    on_stdout = on_output,
    on_stderr = on_output,
  })
  self.job:start()
  return
end

function Previewer:stop(opts)
  self.job:shutdown()
end

return Previewer
