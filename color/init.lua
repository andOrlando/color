COLOR_DIR = (...):match("(.-)[^%.]+$").."color."

return {
  color = require'color',
  transition = require'transition',
  utils = require'utils'
}
