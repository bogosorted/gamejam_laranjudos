extends Node

@export var player: RigidBody2D
@export var G: float = 100.0

var planets: Array[Node2D] = []



func _physics_process(delta: float) -> void:
	if planets.is_empty():
		planets.assign(get_tree().get_nodes_in_group("planets"))
		planets.sort_custom(func(a, b): return a.soi_radius < b.soi_radius)

	var planet_with_gravity_influence = null
	
	for planet in planets:
		var planet_distance = player.global_position.distance_to(planet.global_position)
		
		if planet_distance <= planet.soi_radius:
			planet_with_gravity_influence = planet
			break

	if planet_with_gravity_influence:
		
		var direction = planet_with_gravity_influence.global_position - player.global_position
		var distance = direction.length()
		
		if distance < 0.5: # evita divisao por zero
			return
			
		# F = (G * M * m) / d^2 * |d|
		var force_vector : Vector2 = G * (planet_with_gravity_influence.mass * player.mass / (distance * distance)) * direction.normalized()
		player.apply_central_force(force_vector)
		
func get_planet_with_gravity_influence(position: Vector2) -> Node2D:
	for planet in planets:
			if position.distance_to(planet.global_position) <= planet.soi_radius:
				return planet
	return null
