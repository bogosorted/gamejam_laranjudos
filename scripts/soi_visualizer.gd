extends Node2D

var parent_planet: Node2D

func _draw() -> void:
	if not parent_planet:
		return
		
	if parent_planet.soi_radius != INF:
		var dash_count = 40
		var angle_step = TAU / dash_count
		
		var soi_color = parent_planet.orbit_color_start
		soi_color.a = 0.5
		
		for i in range(dash_count):
			var start_angle = i * angle_step
			var end_angle = start_angle + (angle_step * 0.5) 
			draw_arc(Vector2.ZERO, parent_planet.soi_radius, start_angle, end_angle, 4, soi_color, parent_planet.soi_line_width)
