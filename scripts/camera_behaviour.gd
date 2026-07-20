extends Camera2D

@export var player: Node2D

#configurações do zoom (scroll)
@export var max_zoom_scale: float = 3
@export var min_zoom_scale: float = 0.001
@export var start_zoom_scale: float = 2.5
@export var scroll_units: float = 0.1

@export var arrow_image: Sprite2D
@export var orbit_predictor: Node2D
@export var sky_material: ColorRect

func _ready() -> void:
	if start_zoom_scale:
		zoom = Vector2(start_zoom_scale, start_zoom_scale)
	orbit_predictor.width = orbit_predictor.default_line_lenght
	
	for planet in get_tree().get_nodes_in_group("planets"):
		planet.soi_line_width = planet.default_soi_line_width * 1 / (4.9 * zoom.x)
		planet.queue_redraw()


func _process(delta: float) -> void:
	if player:
		global_position = player.global_position
		
		if player.name == "Astronaut":
			global_rotation = lerp_angle(global_rotation, player.global_rotation, delta * 5.0)
		else:
			global_rotation = lerp_angle(global_rotation, 0.0, delta * 5.0)
		
	sky_material.material.set_shader_parameter("cam_pos", global_position)
		
#metodo que calcula o zoom in e zoom out
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var new_zoom = zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_zoom = zoom * (1.0 + scroll_units)
			
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_zoom = zoom * (1.0 - scroll_units)
		
		zoom.x = clamp(new_zoom.x, min_zoom_scale, max_zoom_scale)
		zoom.y = clamp(new_zoom.y, min_zoom_scale, max_zoom_scale)
		
		orbit_predictor.width = orbit_predictor.default_line_lenght * 1/ (4.9 *zoom.x)
		
		for planet in get_tree().get_nodes_in_group("planets"):
			planet.soi_line_width = planet.default_soi_line_width * 1 / (4.9 * zoom.x)
			planet.queue_redraw()
			
		if new_zoom.x < 0.008	:
			arrow_image.visible = true
			arrow_image.scale = Vector2(1/(3*zoom.x),1/(3*zoom.y))
		else:
			arrow_image.visible = false
