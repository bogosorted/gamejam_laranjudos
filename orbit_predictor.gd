extends Line2D

@export var player: RigidBody2D
@export var planet: StaticBody2D
@export var gravity_behavior: Node
@export var step_count: int = 500 
@export var step_delta: float = 0.02 

var planet_radius: float = 100.0

func _ready() -> void:
	top_level = true
	_calculate_planet_radius()

func _process(_delta: float) -> void:
	if not player or not planet or not gravity_behavior:
		clear_points()
		return
	clear_points()
	var G: float = gravity_behavior.get("G") if "G" in gravity_behavior else 6.67
	
	var start_pos = player.global_position
	var sim_pos = start_pos
	var sim_vel = player.linear_velocity
	
	var p_mass: float = planet.get("mass") if "mass" in planet else 1000000.0
	var player_mass: float = player.mass

	for i in range(step_count):
		add_point(sim_pos)
		
		var diff = planet.global_position - sim_pos
		var distance = diff.length()
		
		if distance <= planet_radius:
			break
			
		if i > 50 and sim_pos.distance_to(start_pos) < 30.0:
			break
			
		var direction = diff.normalized()
		var force = direction * (G * p_mass * player_mass / (distance * distance))
		var acceleration = force / player_mass
		
		sim_vel += acceleration * step_delta
		sim_pos += sim_vel * step_delta

func _calculate_planet_radius() -> void:
	if not planet:
		return
	for child in planet.get_children():
		if child is CollisionShape2D and child.shape:
			if child.shape is CircleShape2D:
				planet_radius = child.shape.radius * child.global_scale.x
				return
