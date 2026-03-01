-- Function to automatically get screen and workarea geometry
local function get_auto_geometry()
    -- Default values (if commands fail to run)
    local sw, sh = 1920, 1080
    local wx, wy, ww, wh = 0, 0, 1920, 1080

    -- Get total screen resolution
    local f = io.popen("xrandr --current | grep '*' | head -n1")
    if f then
        local line = f:read("*a")
        f:close()
        local w, h = line:match("(%d+)x(%d+)")
        sw, sh = tonumber(w) or sw, tonumber(h) or sh
    end

    -- Get workarea (usable area)
    -- Format: x, y, width, height (y is the offset for top/bottom panels)
    local f_wa = io.popen("xprop -root _NET_WORKAREA")
    if f_wa then
        local line = f_wa:read("*a")
        f_wa:close()
        local x, y, w, h = line:match("= (%d+), (%d+), (%d+), (%d+)")
        wx, wy, ww, wh = tonumber(x) or wx, tonumber(y) or wy, tonumber(w) or ww, tonumber(h) or wh
    end

    return sw, sh, wx, wy, ww, wh
end

-- Extract geometry
local sw, sh, wx, wy, ww, wh = get_auto_geometry()

-- Calculate settings
local alignment = "top_right"
local final_height = wh
local gap_y = 0

-- If the panel is at the top, wy > 0, so the widget needs to start lower
if alignment == "top_right" then
    gap_y = wy
-- If the panel is at the bottom, wy will be 0, but wh < sh. gap_y is the distance from top.
elseif alignment == "bottom_right" then
    gap_y = sh - (wy + wh)
end

-- Environment variables can override the automatic detection
final_height = tonumber(os.getenv("PANEL_HEIGHT")) or final_height
gap_y = tonumber(os.getenv("TRAY_HEIGHT")) or gap_y

conky.config = {
	update_interval = 1,

	background = false,
	alignment = alignment,

	border_width = 0,
	border_inner_margin = 0,
	border_outer_margin = 0,

	draw_borders = false,
	draw_graph_borders = false,

	minimum_width = 250,
	minimum_height = final_height,

	gap_x = 0,
	gap_y = gap_y,

	override_utf8_locale = true,

	double_buffer = true,
	no_buffers = true,

	text_buffer_size = 2048,
	imlib_cache_size = 0,

	own_window = true,
	own_window_type = "normal",
	own_window_transparent = true,
	own_window_argb_visual = true,
	own_window_argb_value = 0,
	own_window_hints = "undecorated,below,sticky,skip_taskbar,skip_pager",

	draw_shades = false,
	draw_outline = false,

	use_xft = true,
	xftalpha = 0.8,

	uppercase = false,

	lua_load = "panelMain.lua",
	lua_draw_hook_pre = "panelMain",
};

conky.text = [[ ]];
