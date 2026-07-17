extends Line2D


@export var player: RigidBody2D
@export var planet: StaticBody2D
@export var gravity_behavior: Node
@export var step_count: int = 500 
@export var step_delta: float = 0.02 


@export var orbit_color: Color = Color.AQUA
@export var orbit_middle: Color = Color.AQUA
@export var orbit_final: Color = Color.AQUA


@export var complete_orbit_middle: Color = Color.AQUA
@export var complete_orbit_color: Color = Color.AQUA

@export var default_line_lenght: float = 25.0
var planet_radius: float

func _ready() -> void:
	_calculate_planet_radius()
	width = default_line_lenght
	

func _process(_delta: float) -> void:
	
	clear_points()
	
	var G: float = gravity_behavior.get("G") 
	
	var start_pos = player.global_position
	var point_pos = start_pos
	var velocity = player.linear_velocity
	var vector_planet_to_player = (start_pos - planet.global_position).normalized()
	var planet_mass: float = planet.get("mass")
	var orbit_complete: bool = false
	var player_mass: float = player.mass
	var has_passed_other_side: bool = false
	
	for i in range(step_count):
		add_point(point_pos)
		
		var direction = planet.global_position - point_pos
		var direction_normalized = direction.normalized()
		var distance = direction.length()

		if distance <= planet_radius:
			remove_point(get_point_count() - 1) 
			
			var surface_pos = planet.global_position - (direction_normalized * planet_radius)
			add_point(surface_pos)
			break
		else:
			if (-direction_normalized).dot(vector_planet_to_player) < -0.9:
				orbit_complete = true
			
		if i > 50 and point_pos.distance_to(start_pos) < 60.0 and orbit_complete:
			#em orbita
			var line_gradient = Gradient.new()
			line_gradient.set_color(0, complete_orbit_color)
			line_gradient.add_point(0.6, complete_orbit_middle)
			line_gradient.set_color(2, complete_orbit_color)
			gradient = line_gradient
			break
		else:
			#rota de colisão com o planeta / suborbital
			var line_gradient = Gradient.new()
			line_gradient.set_color(0, orbit_color)
			line_gradient.add_point(0.6, orbit_middle)
			line_gradient.set_color(2, orbit_final)
			gradient = line_gradient
			
			
		# F = (G * M * m) / d^2 * |d| 
		var force_vector : Vector2 = G * (planet_mass * player_mass / (distance * distance)) * direction.normalized()

		#aceleração do player de encontro com o planeta
		var acceleration = force_vector / player_mass
		
		velocity += acceleration * step_delta
		point_pos += velocity * step_delta

func _calculate_planet_radius() -> void:
	if not planet:
		return
	for child in planet.get_children():
		if child is CollisionShape2D and child.shape:
			if child.shape is CircleShape2D:
				planet_radius = child.shape.radius * child.global_scale.x
				return
