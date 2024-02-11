-- vim: ft=lua tw=80

-- Rerun tests only if their modification time changed.
std = 'luajit'

cache = true

ignore = {
  '212', -- Unused argument
  '121', -- Setting global variable values
  '122', -- Setting global variable fields
}

read_globals = {
  'snippet',
  'f',
  'i',
  't',
  'c',
  'd',
  'p',
  'sn',
  'rep',
  'fmt',
  'mines',
  'map',
  'augroup',
  'command',
  'bit',
  'vim',
  'python',
  'P',
  'R',
  'RELOAD',
  'PASTE',
  'STORAGE',
  'use',
  'describe',
  'it',
  'before_each',
  'assert',
  'map',
}
