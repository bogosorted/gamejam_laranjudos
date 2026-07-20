extends Node

@export var transition_speed: float = 2.0

@export var default_time_scale = 1.0
var target_time_scale: float

func _ready() -> void:
	Engine.time_scale = default_time_scale
	target_time_scale = default_time_scale

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_1) || Input.is_action_pressed("move_up"):
		target_time_scale = default_time_scale
	elif Input.is_key_pressed(KEY_2):
		target_time_scale = default_time_scale * 3
	elif Input.is_key_pressed(KEY_3):
		target_time_scale =  default_time_scale * 8
	elif Input.is_key_pressed(KEY_4):
		target_time_scale = default_time_scale * 16

	Engine.time_scale = move_toward(Engine.time_scale, target_time_scale, transition_speed * delta)
