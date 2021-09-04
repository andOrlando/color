-- much help from https://www.niwa.nu/2013/05/math-behind-colorspace-conversions-rgb-hsl/
-- basically a lua implementation of the above link

-- Helper "round" method
local function round(x, p)
	local power = 10 ^ (p or 0)
	return (x * power + 0.5 - (x * power + 0.5) % 1) / power
end

-- Useful public methods
local function hex_to_rgba(hex)
	hex = hex:gsub("#", "")
	return
		tonumber("0x"..hex:sub(1,2)),
		tonumber("0x"..hex:sub(3,4)),
		tonumber("0x"..hex:sub(5,6)),
		--if alpha exists in hex, return it
		#hex == 8 and tonumber("0x"..hex:sub(7,8)) or nil
end

local function rgba_to_hex(obj)
	local r = obj.r or obj[1]
	local g = obj.g or obj[2]
	local b = obj.b or obj[3]
	local a = obj.a or 1
	local h = (obj.hashtag or obj[4]) and "#" or ""
	return h..string.format("%02x%02x%02x",
			math.floor(r),
			math.floor(g),
			math.floor(b))
			--this part only shows the alpha channel if it's not 1
			..(a ~= 1 and string.format("%02x", math.floor(a*255)) or "")
end

--disclaimer I have no idea what any of the math does
local function rgb_to_hsl(obj)
	local r = obj.r or obj[1]
	local g = obj.g or obj[2]
	local b = obj.b or obj[3]

	local R, G, B = r / 255, g / 255, b / 255
	local max, min = math.max(R, G, B), math.min(R, G, B)
	local l, s, h

	-- Get luminance
	l = (max + min) / 2

	-- short circuit saturation and hue if it's grey to prevent divide by 0
	if max == min then
		s = 0
		h = obj.h or obj[4] or 0
		return
	end

	-- Get saturation
	if l <= 0.5 then s = (max - min) / (max + min)
	else s = (max - min) / (2 - max - min)
	end

	-- Get hue
	if max == R then h = (G - B) / (max - min) * 60
	elseif max == G then h = (2.0 + (B - R) / (max - min)) * 60
	else h = (4.0 + (R - G) / (max - min)) * 60
	end

	-- Make sure it goes around if it's negative (hue is a circle)
	if h ~= 360 then h = h % 360 end

	return h, s, l
end

--no clue about any of this either
local function hsl_to_rgb(obj)
	local h = obj.h or obj[1]
	local s = obj.s or obj[2]
	local l = obj.l or obj[3]

	local temp1, temp2, temp_r, temp_g, temp_b, temp_h

	-- Set the temp variables
	if l <= 0.5 then temp1 = l * (s + 1)
	else temp1 = l + s - l * s
	end

	temp2 = l * 2 - temp1

	temp_h = h / 360

	temp_r = temp_h + 1/3
	temp_g = temp_h
	temp_b = temp_h - 1/3


	-- Make sure it's between 0 and 1
	if temp_r ~= 1 then temp_r = temp_r % 1 end
	if temp_g ~= 1 then temp_g = temp_g % 1 end
	if temp_b ~= 1 then temp_b = temp_b % 1 end

	local rgb = {}

	-- Bunch of tests
	-- Once again I haven't the foggiest what any of this does
	for _, v in pairs({{temp_r, "r"}, {temp_g, "g"}, {temp_b, "b"}}) do

		if v[1] * 6 < 1 then rgb[v[2]] = temp2 + (temp1 - temp2) * v[1] * 6
		elseif v[1] * 2 < 1 then rgb[v[2]] = temp1
		elseif v[1] * 3 < 2 then rgb[v[2]] = temp2 + (temp1 - temp2) * (2/3 - v[1]) * 6
		else rgb[v[2]] = temp2
		end

	end

	return
		round(rgb.r * 255),
		round(rgb.g * 255),
		round(rgb.b * 255)
end

local function color(args)
	-- The object that will be returned
	local obj = {}

	-- Default properties here
	args.r = args.r or 0
	args.g = args.g or 0
	args.b = args.b or 0
	args.h = args.h or 0
	args.s = args.s or 0
	args.l = args.l or 0
	args.a = args.a or 1
	args.hex = args.hex or "000000"
	args.hex = args.hex:gsub("#", "")
	obj._props = args

	-- Default actual normal properties
	obj.hashtag = args.hashtag or true
	obj.disable_hsl = args.disable_hsl or false

	-- Set access to any
	obj._access = "rgbhslhex"

	--temporary values
	--alpha since it can be nil and don't wanna overwrite,
	--hex_no_alpha just as a placeholder in _alphaize_hex
	local alpha, hex_no_alpha

	-- Methods and stuff
	function obj:_hex_to_rgba()
		obj._props.r, obj._props.g, obj._props.b, alpha = hex_to_rgba(obj._props.hex)
		if not alpha then self._props.a = alpha end
	end
	function obj:_rgba_to_hex()
		obj._props.hex = rgba_to_hex(obj._props)
	end
	function obj:_rgb_to_hsl()
		obj._props.h, obj._props.s, obj._props.l = rgb_to_hsl(obj._props)
	end
	function obj:_hsl_to_rgb()
		obj._props.r, obj._props.g, obj._props.b = hsl_to_rgb(obj._props)
	end
	function obj:_alphaize_hex()
		hex_no_alpha = #obj._props.hex == 6 and obj._props.hex or obj._props.hex:sub(1, 6)
		obj._props.hex = hex_no_alpha..(obj._props.a ~= 1
			and string.format("%02x", math.floor(obj._props.a*255)) or "")
	end
	function obj:set_no_update(key, value)
		obj._props[key] = value
	end

	-- Initially set other values
	if obj._props.r ~= 0 or obj._props.g ~= 0 or obj._props.b ~= 0 then
		obj:_rgba_to_hex()
		if not obj.disable_hsl then obj:_rgb_to_hsl() end

	elseif obj._props.hex ~= "000000" then
		obj:_hex_to_rgba()
		if not obj.disable_hsl then obj:_rgb_to_hsl() end

	elseif obj._props.h ~= 0 or obj._props.s ~= 0 or obj._props.l ~= 0 then
		obj:_hsl_to_rgb()
		obj:_rgba_to_hex()

	end --otherwise it's just black and everything is correct already


	-- Set up the metatable
	local mt = getmetatable(obj) or {}

	-- Check if it's already in _props to return it
	-- TODO: Only remake values if necessary
	mt.__index = function(self, key)
		if self._props[key] then
			-- Check if to just return nil for hsl
			if obj.disable_hsl and string.match("hsl", key) then return self._props[key] end

			-- Check if it's not currently accessible
			if not string.match(obj._access, key) then


				if obj._access == "rgb" then
					self:_rgba_to_hex()
					if not obj.disable_hsl then obj:_rgb_to_hsl() end

				elseif obj._access == "hex" then
					self:_rgba_to_hex()
					if not obj.disable_hsl then obj:_rgb_to_hsl() end

				elseif obj._access == "hsl" then
					self:_hsl_to_rgb()
					self:_rgba_to_hex()

				elseif obj._access == "rgbhsla" then
					self:_alphaize_hex()
				end


				-- Reset accessibleness
				obj._access = "rgbhexhsla"
			end

			-- Check for hashtaginess
			if obj.hashtag and key == "hex" then return "#"..self._props.hex end

			return self._props[key]

		else return self.class.__classDict[key] end
	end

	mt.__newindex = function(self, key, value)
		if self._props[key] ~= nil then

			-- Set basic important stuff
			self._props[key] = value

			-- Set what values are currently accessible
			if string.match("rgb", key) then obj._access = "rgb"
			elseif string.match("hsl", key) and not obj.disable_hsl then obj._access = "hsl"
			elseif string.match("hex", key) then obj._access = "hex"
			elseif key == "a" then obj._access = "rgbhsla"
			end

		-- If it's not part of _props just normally set it
		else rawset(self, key, value) end
	end

	setmetatable(obj, mt)
	return obj
end

return {
	color = color,
	hex_to_rgba = hex_to_rgba,
	rgba_to_hex = rgba_to_hex,
	rgb_to_hsl = rgb_to_hsl,
	hsl_to_rgb = hsl_to_rgb
}
