-- @author cedlemo  

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type = type
local string = string
local color = require("gears.color")
local base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
local superproperties = require("blingbling.superproperties")
local lgi = require("lgi")
local pango = lgi.Pango
local pangocairo = lgi.PangoCairo
---A text box  

local text_box = { mt = {} }
local data = setmetatable({}, { __mode = "k" })

---Fill all the widget with this color (default is transparent).
--@usage myt_box:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param t_box the value text box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border (width * height) with this color (default is none ) 
--@usage myt_box:set_background_border(string) -->"#rrggbbaa"
--@name set_background_border
--@class function
--@t_box t_box the t_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the text area (text height/width + padding) background with this color (default is none)
--@usage myt_box:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param t_box the t_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a border on the text area background (default is none ) 
--@usage myt_box:set_text_background_border(string) -->"#rrggbbaa"
--@name set_text_background_border
--@class function
--@t_box t_box the t_box
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the top and bottom margin for the text background 
--@usage myt_box:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param t_box the value text box
--@param margin an integer for top and bottom margin

---Define the left and right margin for the text background
--@usage myt_box:set_h_margin(integer) 
--@name set_h_margin
--@class function
--@param t_box the value text box
--@param margin an integer for left and right margin

---Set rounded corners for background and text background
--@usage myt_box:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param t_box the value text box
--@param rounded_size float in [0,1]

---Define the color of the text  
--@usage myt_box:set_text_color(string) 
--@name set_text_color
--@class function
--@param t_box the value text box
--@param color a string "#rrggbb" 

---Define the text font size
--@usage myt_box:set_font_size(integer)
--@name set_font_size
--@class function
--@param t_box the value text box
--@param size the font size

local properties = {    "width", "height", "h_margin", "v_margin", 
                        "background_border", "background_color", 
                        "background_text_border", "background_text_color",
                        "rounded_size", "text_color", "font_size", "font"
                   }

 -- Setup a pango layout for the given textbox and cairo context
local function setup_layout(t_box, width, height)
	local layout = t_box._layout
  layout.width = pango.units_from_double(width)
  layout.height = pango.units_from_double(height)
end

local function draw( t_box, wibox, cr, width, height)

  local background_border = data[t_box].background_border or superproperties.background_border
  local background_color = data[t_box].background_color or superproperties.background_color
	local rounded_size = data[t_box].rounded_size or superproperties.rounded_size
  local text_color = data[t_box].text_color or superproperties.text_color
  local background_text_color = data[t_box].background_text_color or superproperties.background_text_color
  local font_size =data[t_box].font_size or superproperties.font_size
  local font = data[t_box].font or superproperties.font
  local text = data[t_box].text

  if type(font) ~= "string" and type(font) == "table" then
    font = (font.family or "Sans") ..(font.slang or "normal") ..( font.weight or "normal")
  end
  
	layout = t_box._layout
	cr:update_layout(layout)
	font_desc = pango.FontDescription.from_string(font .. " " .. font_size)
	layout:set_font_description(font_desc)
	layout.text = text
  layout:set_markup("<span color='"..text_color.."'>"..text.."</span>" )
  local ink, logical = layout:get_pixel_extents()
	local height =0
	local width = 0
	width = logical.width
  data[t_box].width = logical.width
	height = logical.height
  data[t_box].height = logical.height

	local v_margin =  superproperties.v_margin  
  if data[t_box].v_margin and data[t_box].v_margin <= height/3 then 
    v_margin = data[t_box].v_margin 
  end
  local h_margin = superproperties.h_margin 
  if data[t_box].h_margin and data[t_box].h_margin <= width / 3 then 
    h_margin = data[t_box].h_margin 
  end
	setup_layout(t_box, width, height)
  
	--Generate Background (background widget)
  if data[t_box].background_color then
    helpers.draw_rounded_corners_rectangle( cr,
                                            0,
                                            0,
                                            data[t_box].width, 
                                            data[t_box].height,
                                            background_color, 
                                            rounded_size,
                                            background_border
                                            )
  
  end
  
  --Draw nothing, or filled ( value background)
  if data[t_box].background_text_color then
    --draw rounded corner rectangle
    local x=h_margin
    local y=v_margin
    
    helpers.draw_rounded_corners_rectangle( cr,
                                            x,
                                            y,
                                            data[t_box].width - h_margin, 
                                            data[t_box].height - v_margin, 
                                            background_text_color, 
                                            rounded_size,
                                            background_text_border
                                            )
  end  

  cr:move_to(0,0)
	cr:show_layout(layout)
end

function text_box:fit( width, height)
	setup_layout(self, width, height)
	local ink, logical = self._layout:get_pixel_extents()
		 
	if logical.width == 0 or logical.height == 0 then
	   return 0, 0
	end
	 
	return logical.width, logical.height
end

--- Add a text to the t_box
-- For compatibility between old and new awesome widget, add_value can be replaced by set_value
-- @usage myt_box:add_value(a) or myt_box:set_value(a)
-- @param t_box The t_box.
-- @param text a string.
local function set_text(t_box, string)
    if not t_box then return end

		local text = string or ""
		
    data[t_box].text = text
		t_box._layout.text = text
    t_box:emit_signal("widget::updated")
    return t_box
end


--- Set the t_box height.
-- @param t_box The t_box.
-- @param height The height to set.
function text_box:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the t_box width.
-- @param t_box The t_box.
-- @param width The width to set.
function text_box:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not text_box["set_" .. prop] then
        text_box["set_" .. prop] = function(t_box, value)
            data[t_box][prop] = value
            t_box:emit_signal("widget::updated")
            return t_box
        end
    end
end

--- Create a t_box widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set t_box geometry.
-- @return A t_box widget.
function text_box.new(args)
    local args = args or {}

    args.width = args.width or 5 
    args.height = args.height or 5

    if args.width < 5 or args.height < 5 then return end

    local t_box = base.make_widget()
    data[t_box] = {}
    
		data[t_box].text = args.text or ""
    for _, v in ipairs(properties) do
      data[t_box][v] = args[v] 
    end
    local ctx = pangocairo.font_map_get_default():create_context()
    t_box._layout = pango.Layout.new(ctx)

    -- Set methods
    t_box.set_text = set_text
    t_box.draw = draw
    t_box.fit = text_box.fit

    for _, prop in ipairs(properties) do
        t_box["set_" .. prop] = text_box["set_" .. prop]
    end

    return t_box
end
function text_box.mt:__call(...)
    return text_box.new(...)
end

return setmetatable(text_box, text_box.mt)

