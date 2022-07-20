require 'cairo'

function conky_main()

	if conky_window == nil then
		return
	end

	local cs = cairo_xlib_surface_create(conky_window.display,
					     conky_window.drawable,
					     conky_window.visual,
					     conky_window.width,
					     conky_window.height)
	cr = cairo_create(cs)

	if (io.open("/sys/class/power_supply/BAT0/uevent")) then
		battery = conky_parse("${battery}")
		draw_chart(cr, 'Battery', string.match(battery, "%d+"), 255, 700)
	else
		draw_chart(cr, 'Battery', 0, 255, 700)
	end

	cpu = conky_parse("${cpu}")
	draw_chart(cr, 'CPU', cpu, 150, 500)

	ram = conky_parse("${memperc}")
	draw_chart(cr, 'RAM', ram, 375, 600)

	storage = string.match(conky_parse("${fs_used}"), "%d+") / string.match(conky_parse("${fs_size}"), "%d+") * 100
	draw_chart(cr, 'Strage', math.floor(storage), 450, 800)

	--print(conky_parse("${upspeed wlo1}"))
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr = nil

end

function draw_chart(cr, resource, value, x, y)

	r = 65
	start_angle = -90*math.pi/180
	end_angle = 270*math.pi/180

	cairo_set_line_width(cr, 1)
	cairo_set_source_rgba(cr, 1, 1, 1, 1)
	cairo_arc(cr, x, y, r-5, start_angle, end_angle)
	cairo_arc(cr, x, y, r+5,start_angle, end_angle)

	cairo_set_font_size (cr, 37.5)
	local extents = cairo_text_extents_t:create()
	cairo_text_extents(cr, tostring(value), extents)
	cairo_move_to(cr, x-extents.width/2, y+5)
	cairo_show_text(cr, tostring(value))
	cairo_set_font_size(cr, 15)
	cairo_text_extents(cr, resource, extents)
	cairo_move_to(cr, x-extents.width/2, y+30)
	cairo_show_text(cr, resource)
	
	cairo_stroke(cr)
	
	cairo_set_line_width(cr, 10)
	cairo_arc(cr, x, y, r,start_angle, (value*360/100-90)*math.pi/180)  
	cairo_stroke(cr)

end
