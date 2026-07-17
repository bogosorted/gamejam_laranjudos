extends Camera2D

@export var player: Node2D

#configurações do zoom (scroll)
@export var max_zoom_scale: float = 3
@export var min_zoom_scale: float = 0.001
@export var start_zoom_scale: float = 1
@export var scroll_units: float = 0.1

func _ready() -> void:
	if start_zoom_scale:
		zoom = Vector2(start_zoom_scale, start_zoom_scale)

func _process(delta: float) -> void:
	if player:
		global_position = player.global_position
		
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
