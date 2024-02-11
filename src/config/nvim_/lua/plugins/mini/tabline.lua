local highlight = mines.highlight

highlight.plugin('MiniTablne', {
  { CmpItemKindVariable = { link = 'Variable' } },
  { MiniTablineVisible = { link = 'TabLineSel' } },
  { MiniTablineHidden = { link = 'TabLine' } },
  { MiniTablineModifiedCurrent = { link = 'StatusLine' } },
  { MiniTablineModifiedVisible = { link = 'StatusLine' } },
  { MiniTablineModifiedHidden = { link = 'StatusLineNC' } },
  { MiniTablineTabpagesection = { link = 'Search' } },
  { MiniTablineFill = { link = 'TabLineFill' } },
})

return {
  'echasnovski/mini.tabline',
  event = 'VeryLazy',
  config = function()
    require('mini.tabline').setup {
      set_vim_settings = false,
      tabpage_section = 'right',
    }
  end,
}
