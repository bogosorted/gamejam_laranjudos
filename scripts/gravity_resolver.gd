extends Node

@export var player: RigidBody2D
@export var G: float = 100.0

var planets: Array[Node2D] = []


func _ready() -> void:
	planets.assign(get_tree().get_nodes_in_group("planets"))
	
func _process(delta: float) -> void:
	
	pass
func _physics_process(delta: float) -> void:
	if planets.is_empty():
		planets.assign(get_tree().get_nodes_in_group("planets"))
		
	for planet in planets:
		
		var direction = planet.global_position - player.global_position
		var distance = direction.length()
		
		if distance < 0.5: # evita divisao por zero
			continue
			
		# F = (G * M * m) / d^2 * |d|
		var force_vector : Vector2 = G * (planet.mass * player.mass / (distance * distance)) * direction.normalized()
		player.apply_central_force(force_vector)
		
	pass
