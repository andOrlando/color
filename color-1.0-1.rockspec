package = "color"
version = "1.0-1"
source = {
   url = "git+https://github.com/andOrlando/color.git"
}
description = {
   detailed = [[
Allows for easy access to rgb, hsl or hex from any one of the three as well
as efficient computation of other values when one changes. If you update
a color's `h` value then access it's `hex` value, it will calculate the new
`hex` value based on the updated `h`. If you update the `h` value and then
access the `s` value, it will not update any other values. The README
in the github has a better description
   ]],
   homepage = "https://github.com/andOrlando/color",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      color = "color.lua"
   }
}
