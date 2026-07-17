extends StaticBody2D

@export var mass: float = 500.0
func _ready() -> void:
	add_to_group("planets")
