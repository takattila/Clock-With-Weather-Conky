local draw = {}

-- Store history for each chart
local cpu_hist = {}
local mem_hist = {}
local net_up_hist = {}
local net_down_hist = {}
local max_points = 100 -- Number of data points to display on the chart

function hex2rgb(hex)
	local hex = hex:gsub("#","")
	return (tonumber("0x"..hex:sub(1,2))/255), 
		(tonumber("0x"..hex:sub(3,4))/255), 
		tonumber(("0x"..hex:sub(5,6))/255)
end

-- Helper function to update data history
local function update_history(hist, value)
	table.insert(hist, value)
	if #hist > max_points then
		table.remove(hist, 1)
	end
end

-- Helper to find the maximum value in a history table for dynamic scaling
local function get_dynamic_max(hist, min_ceiling)
	local max = min_ceiling or 1
	for _, v in ipairs(hist) do
		if v > max then max = v end
	end
	return max * 1.1 -- Add 10% headroom so the line doesn't touch the very top
end

function draw_line_chart(cr, x, y, w, h, data, label, color_hex, max_val, suffix)
	local r, g, b = hex2rgb(color_hex)
	local current_val = data[#data] or 0
	
	-- 1. Fancy Title (Large and Bold)
	cairo_select_font_face(cr, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size(cr, 22) 
	cairo_set_source_rgba(cr, r, g, b, 0.9)
	cairo_move_to(cr, x, y - 25)
	cairo_show_text(cr, label:upper())

	-- 2. Current measurement (below the title)
	-- Format: switch to MiB/s if value is high
	local display_val = current_val
	local display_suffix = suffix
	if suffix == " KiB/s" and current_val > 1024 then
		display_val = current_val / 1024
		display_suffix = " MiB/s"
	end

	cairo_select_font_face(cr, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 14)
	cairo_set_source_rgba(cr, 1, 1, 1, 0.7)
	cairo_move_to(cr, x, y - 8)
	cairo_show_text(cr, "Current: " .. string.format("%.1f", display_val) .. display_suffix)

	-- 3. Chart Background
	cairo_set_source_rgba(cr, 1, 1, 1, 0.05)
	cairo_rectangle(cr, x, y, w, h)
	cairo_fill(cr)

	-- 4. Line and area fill
	if #data > 1 then
		cairo_set_line_width(cr, 2.0)
		cairo_set_source_rgba(cr, r, g, b, 0.8)
		
		local step = w / (max_points - 1)
		
		for i = 1, #data do
			local val_h = (data[i] / max_val) * h
			if val_h > h then val_h = h end
			
			local posX = x + (i-1) * step
			local posY = y + h - val_h
			
			if i == 1 then
				cairo_move_to(cr, posX, posY)
			else
				cairo_line_to(cr, posX, posY)
			end
		end
		cairo_stroke_preserve(cr)
		
		local lastX = x + (#data - 1) * step
		cairo_line_to(cr, lastX, y + h)
		cairo_line_to(cr, x, y + h)
		cairo_close_path(cr)
		cairo_set_source_rgba(cr, r, g, b, 0.15)
		cairo_fill(cr)
	end
end

function draw.elements(cr)
	local w_height = conky_window.height
	local w_width = conky_window.width
	
	if w_height <= 0 then return end

	local sections = 4
	local gap = 20
	local section_height = w_height / sections
	local title_space = 50 
	local chart_h = section_height - title_space - gap
	local chart_w = w_width - 20
	local chart_x = 10

	local color_light = settings.appearance.font.color.light
	local color_dark = settings.appearance.font.color.dark

	-- Data collection
	local cpu = tonumber(conky_parse("${cpu cpu0}")) or 0
	local mem = tonumber(conky_parse("${memperc}")) or 0
	
	local iface = conky_parse("${gw_iface}")
	if iface == "" or iface == nil or iface == "(null)" or iface == "multiple" then 
		iface = conky_parse("${exec ip route get 8.8.8.8 | grep -Po '(?<=dev )\\S+' | head -1}")
	end
	if iface == "" or iface == nil then iface = "eth0" end
	
	local net_up = tonumber(conky_parse("${upspeedf " .. iface .. "}")) or 0
	local net_down = tonumber(conky_parse("${downspeedf " .. iface .. "}")) or 0

	-- History update
	update_history(cpu_hist, cpu)
	update_history(mem_hist, mem)
	update_history(net_up_hist, net_up)
	update_history(net_down_hist, net_down)

	-- Calculate dynamic ceilings for network charts
	-- We use 1024 KiB/s as a base minimum ceiling
	local dynamic_down_max = get_dynamic_max(net_down_hist, 1024)
	local dynamic_up_max = get_dynamic_max(net_up_hist, 512)

	-- Draw charts
	for i = 0, sections - 1 do
		local y_offset = (section_height * i) + title_space
		
		if i == 0 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, cpu_hist, "CPU", color_light, 100, "%")
		elseif i == 1 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, mem_hist, "Memory", color_dark, 100, "%")
		elseif i == 2 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, net_down_hist, "Net Down", color_light, dynamic_down_max, " KiB/s")
		elseif i == 3 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, net_up_hist, "Net Up", color_dark, dynamic_up_max, " KiB/s")
		end
	end
end

return draw
