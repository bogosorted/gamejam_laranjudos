extends Line2D


@export var player: RigidBody2D
@export var gravity_behavior: Node
@export var step_count: int = 500 
@export var step_delta: float = 0.01





@export var complete_orbit_middle: Color = Color.AQUA
@export var complete_orbit_color: Color = Color.AQUA

@export var default_line_lenght: float = 25.0

var planet_radius: float
var is_in_orbit: bool = false

func _ready() -> void:
	width = default_line_lenght
	

func _physics_process(_delta: float) -> void:
	#if (not Input.is_action_pressed("move_up"))  and last_draw < 0.5: 
		#return 
		
	clear_points()
	is_in_orbit = false
	
	var G: float = gravity_behavior.get("G") 
	
	var start_pos = player.global_position
	var point_pos = start_pos
	var velocity = player.linear_velocity
	
	var orbit_complete: bool = false
	var player_mass: float = player.mass
	
	var last_soi_planet = null
	var soi_switches = []
	

	for i in range(step_count):
		add_point(point_pos)
		
		var in_soi_of = gravity_behavior.get_planet_with_gravity_influence(point_pos)
		
		if in_soi_of == null:
			break
			
		if in_soi_of != last_soi_planet:
			if soi_switches.size() >= 2:
				break
				
			soi_switches.append({"index": get_point_count() - 1, "planet": in_soi_of})
			last_soi_planet = in_soi_of
	
		var direction = in_soi_of.global_position - point_pos
		var direction_normalized = direction.normalized()
		var distance = direction.length()
		
		var vector_planet_to_player = (start_pos - in_soi_of.global_position).normalized()
		var planet_mass: float = in_soi_of.get("mass")
		_calculate_planet_radius(in_soi_of)

		if distance <= planet_radius:
			remove_point(get_point_count() - 1) 
			
			var surface_pos = in_soi_of.global_position - (direction_normalized * planet_radius)
			add_point(surface_pos)
			break
		else:
			if (-direction_normalized).dot(vector_planet_to_player) < -0.9:
				orbit_complete = true
			
		if i > 50 and point_pos.distance_to(start_pos) < 60.0 and orbit_complete:
			#em orbita
			is_in_orbit = true
			break
			
		var force_vector : Vector2 = G * (planet_mass * player_mass / (distance * distance)) * direction.normalized()
		var acceleration = force_vector / player_mass
		
		velocity += acceleration * step_delta
		point_pos += velocity * step_delta

	if is_in_orbit:
		if player and "is_in_stable_orbit" in player:
			player.is_in_stable_orbit = true
		var line_gradient = Gradient.new()
		line_gradient.set_color(0, complete_orbit_color)
		line_gradient.add_point(0.6, complete_orbit_middle)
		line_gradient.set_color(2, complete_orbit_color)
		gradient = line_gradient
	else:
		if player and "is_in_stable_orbit" in player:
			player.is_in_stable_orbit = false
		var line_gradient = Gradient.new()
		var offsets = []
		var colors = []
		
		var dists = [0.0]
		for k in range(1, get_point_count()):
			dists.append(dists[-1] + get_point_position(k).distance_to(get_point_position(k-1)))
		var total_dist = max(1.0, dists[-1])
		
		soi_switches.append({"index": get_point_count() - 1, "planet": last_soi_planet})
		
		for j in range(soi_switches.size() - 1):
			var r_start = dists[soi_switches[j].index] / total_dist
			var r_end = dists[soi_switches[j+1].index] / total_dist
			var p = soi_switches[j].planet
			
			if r_start < r_end:
				offsets.append(r_start)
				colors.append(p.orbit_color_start )
				
				offsets.append(lerp(r_start, r_end, 0.6))
				colors.append(p.orbit_color_middle)
				
				offsets.append(r_end if j == soi_switches.size() - 2 else r_end - 0.0001)
				colors.append(p.orbit_color_end)
				
		if offsets.size() == 0:
			offsets = [0.0, 1.0]
			colors = [Color.AQUA, Color.AQUA]
			
		line_gradient.offsets = PackedFloat32Array(offsets)
		line_gradient.colors = PackedColorArray(colors)
		gradient = line_gradient

func _calculate_planet_radius(planet: Node2D) -> void:
	if not planet:
		return
	for child in planet.get_children():
		if child is CollisionShape2D and child.shape:
			if child.shape is CircleShape2D:
				planet_radius = child.shape.radius * child.global_scale.x
				return
