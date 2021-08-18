# color
Contains a bunch of useful function for conversion as well as well as a very nice api for just colors in general.

It can probably be easiest explained with a code snippet:
```lua
color = require 'color'
dark_green = color.color { r=10, g=30, b=10 }

dark_green.h, dark_green.s, dark_green.l
-- Returns 120.0 0.5 0.07843137254902

dark_green.h = 60
dark_green.r, dark_green.g, dark_green.b
-- Returns 30.0 30.0 10.0
```
As you can see, when you update one variable all the rest update with it. This is done in a relatively intelligent 
manner, however. Should you, in the example of the code snippet, update h, s or l again, it won't try to update the 
other values. Only when you access non-hsl entries will it update them. Once it's updated, you can access anything 
without it updating further until you change something again.

# Useful functions and more info
Furthermore, it comes with a couple nice functions too:
- `hex_to_rgb`: takes in a string hex value (no # as of now) and returns rgb values from 0-255
- `rgb_to_hex`: takes in a table with entries r, g and b and returns a string hex value (with no #)
- `rgb_to_hsl`: takes in a table with entries r, g and b and returns a table with h, s and l
- `hsl_to_rgb`: takes in a table with entries h, s and l and returns a table with r, g and b

A couple more notes about the color class:
- r, g and b must be values between 0 and 255
- s and l must be between 0 and 1, whereas h must be between 0 and 360
- hex (as of now) must not contain its #, but I'm probably gonna add support for that in the future

All the math was taken from [here](https://www.niwa.nu/2013/05/math-behind-colorspace-conversions-rgb-hsl/). 
I basically just put it into lua in a nice way. Me actaully kinda learning how to make this nice api comes
from [here](https://ebens.me/post/implementing-proper-gettersetters-in-lua). Please pardon my godawful codestyle,
I just do what I think looks pleasent, which I suppose is fitting for a ricer.

# TODO
-[ ] cool name??
-[ ] Add better # support for hex
-[ ] Add better checks (asserts and stuff)
-[ ] Add alpha and toggles for whether or not to include it
-[ ] Do better setting of default methods (`obj._props.r = args.r or 0` kinda thing)
-[ ] Make do good readme
-[ ] Have smarter input reading (as in, don't require a table with r, g and b, look at first three indices)
