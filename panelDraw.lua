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

function draw_line_chart(cr, x, y, w, h, data, label, color_hex, max_val, suffix)
	local r, g, b = hex2rgb(color_hex)
	local current_val = data[#data] or 0
	
	-- 1. Fancy Title (Large and Bold)
	cairo_select_font_face(cr, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size(cr, 22) 
	cairo_set_source_rgba(cr, r, g, b, 0.9)
	cairo_move_to(cr, x, y - 25) -- Moved title higher
	cairo_show_text(cr, label:upper())

	-- 2. Current measurement (below the title)
	cairo_select_font_face(cr, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, 14)
	cairo_set_source_rgba(cr, 1, 1, 1, 0.7)
	cairo_move_to(cr, x, y - 8) -- Just below title, above chart
	cairo_show_text(cr, "Current: " .. string.format("%.1f", current_val) .. (suffix or ""))

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
	local gap = 20 -- Static 20px gap between panels
	
	-- Calculate total section height (chart + title + gap)
	local section_height = w_height / sections
	
	-- Fixed space for the two-line header (title + value)
	local title_space = 50 
	-- Actual chart height is the remainder (considering the gap between sections)
	local chart_h = section_height - title_space - gap
	
	local chart_w = w_width - 20
	local chart_x = 10

	-- Data collection
	local cpu = tonumber(conky_parse("${cpu cpu0}")) or 0
	local mem = tonumber(conky_parse("${memperc}")) or 0
	
	local iface = conky_parse("${gw_iface}")
	if iface == "" or iface == nil then iface = "eth0" end
	
	local net_up = tonumber(conky_parse("${upspeedf " .. iface .. "}")) or 0
	local net_down = tonumber(conky_parse("${downspeedf " .. iface .. "}")) or 0

	-- History update
	update_history(cpu_hist, cpu)
	update_history(mem_hist, mem)
	update_history(net_up_hist, net_up)
	update_history(net_down_hist, net_down)

	-- Draw charts
	for i = 0, sections - 1 do
		local y_offset = (section_height * i) + title_space
		
		if i == 0 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, cpu_hist, "CPU", "#ff4444", 100, "%")
		elseif i == 1 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, mem_hist, "Memory", "#44ff44", 100, "%")
		elseif i == 2 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, net_down_hist, "Net Down", "#4444ff", 1000, " KiB/s")
		elseif i == 3 then
			draw_line_chart(cr, chart_x, y_offset, chart_w, chart_h, net_up_hist, "Net Up", "#ffff44", 500, " KiB/s")
		end
	end
end

return draw
