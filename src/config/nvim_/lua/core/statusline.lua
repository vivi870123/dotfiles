local lsp, highlight = mines.ui.lsp, mines.highlight
local P = mines.ui.palette

local hls = highlight.hls

local function colors()
  --- NOTE: Unicode characters including vim devicons should NOT be highlighted
  --- as italic or bold, this is because the underlying bold font is not necessarily
  --- patched with the nerd font characters
  --- terminal emulators like kitty handle this by fetching nerd fonts elsewhere
  --- but this is not universal across terminals so should be avoided

  local indicator_color = P.bright_blue
  local warning_fg = lsp.colors.warn
  local error_color = lsp.colors.error
  local info_color = lsp.colors.info
  local hint_color = lsp.colors.hint
  local normal_fg = highlight.get('Normal', 'fg')
  local string_fg = highlight.get('String', 'fg')
  local number_fg = highlight.get('Number', 'fg')
  local normal_bg = highlight.get('Normal', 'fg')

  local bg_color = highlight.tint(normal_bg, -0.25)

  highlight.all {
    { [hls.metadata] = { bg = bg_color, inherit = 'Comment' } },
    { [hls.metadata_prefix] = { bg = bg_color, fg = { from = 'Comment' } } },
    { [hls.indicator] = { fg = indicator_color } },
    { [hls.modified] = { fg = string_fg } },
    { [hls.git] = { fg = P.light_gray } },
    { [hls.green] = { fg = string_fg } },
    { [hls.blue] = { fg = P.dark_blue, bold = true } },
    { [hls.number] = { fg = number_fg } },
    { [hls.count] = { fg = 'bg', bg = indicator_color, bold = true } },
    { [hls.client] = { bg = bg_color, fg = normal_fg, bold = true } },
    { [hls.env] = { bg = bg_color, fg = error_color, italic = true, bold = true } },
    { [hls.filename] = { bg = bg_color, fg = 'Gray', italic = true } },
    { [hls.filename_inactive] = { bg = bg_color, italic = true, fg = { from = 'Normal', alter = 0.4 } } },
    { [hls.title] = { bg = bg_color, fg = 'LightGray', bold = true } },
    { [hls.comment] = { bg = bg_color, inherit = 'Comment' } },
    { [hls.statusline] = { bg = bg_color } },
    { [hls.statusline_nc] = { link = 'VertSplit' } },
    { [hls.info] = { fg = info_color, bold = true } },
    { [hls.warn] = { fg = warning_fg } },
    { [hls.error] = { fg = error_color } },
    { [hls.hint] = { fg = hint_color } },
    { [hls.recording] = { fg = P.orange } },
    { [hls.mode_normal] = { fg = P.light_gray, bold = true } },
    { [hls.mode_insert] = { fg = P.dark_blue, bold = true } },
    { [hls.mode_visual] = { fg = P.magenta, bold = true } },
    { [hls.mode_replace] = { fg = P.dark_red, bold = true } },
    { [hls.mode_command] = { fg = P.light_yellow, bold = true } },
    { [hls.mode_select] = { fg = P.teal, bold = true } },
  }
end

mines.augroup('CustomStatusline', {
  event = 'ColorScheme',
  command = function() colors() end,
})

colors()
