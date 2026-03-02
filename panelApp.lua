START_PANEL_ENABLED = true

-- Function to detect the monitor index passed to conky via -m flag
local function detect_monitor_index()
    local m_index = 0
    local f = io.open("/proc/self/cmdline", "rb")
    if f then
        local content = f:read("*a")
        f:close()
        -- Command line args in /proc are separated by null bytes (\0)
        -- We look for the sequence: -m <number>
        local match = content:match("%-m%z(%d+)")
        if match then
            m_index = tonumber(match)
        end
    end
    return m_index
end

-- Function to automatically get geometry for a specific monitor
local function get_auto_geometry(m_index)
    local sw, sh = 1920, 1080
    local wx, wy, ww, wh = 0, 0, 1920, 1080

    -- 1. Get the specific monitor resolution using xrandr
    local f_mon = io.popen("xrandr --listmonitors | grep '^ " .. m_index .. ":'")
    if f_mon then
        local line = f_mon:read("*a")
        f_mon:close()
        
        -- Improved regex to capture Width, Height, OffsetX, OffsetY
        local w, h, ox, oy = line:match("(%d+)/?%d*x(%d+)/?%d*%+(%d+)%+(%d+)")
        if w and h then
            sw = tonumber(w)
            sh = tonumber(h)
        end
    end

    -- 2. Get global workarea to detect panel/tray size
    local f_wa = io.popen("xprop -root _NET_WORKAREA")
    if f_wa then
        local line = f_wa:read("*a")
        f_wa:close()
        local x, y, w, h = line:match("= (%d+), (%d+), (%d+), (%d+)")
        wx, wy, ww, wh = tonumber(x) or wx, tonumber(y) or wy, tonumber(w) or ww, tonumber(h) or wh
    end

    return sw, sh, wx, wy, ww, wh
end

-- Auto-detect which monitor conky is running on
local monitor_index = tonumber(os.getenv("MONITOR_INDEX")) or detect_monitor_index()

-- Extract geometry for the current monitor
local sw, sh, wx, wy, ww, wh = get_auto_geometry(monitor_index)

-- Calculate layout
local alignment = "top_right"
local final_height = sh 
local gap_y = 0

-- wy is the global offset (e.g., top panel height)
if alignment == "top_right" then
    gap_y = wy
    final_height = sh - wy
    
    -- Check for bottom panel
    local bottom_offset = sh - (wy + wh)
    if bottom_offset > 0 then
        final_height = final_height - bottom_offset
    end
end

-- Manual overrides
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
