extends StaticBody2D

@export var mass: float = 500.0
@export var radius: float = 3565.0
@export var color: Color = Color.WHITE

@export var orbit_color_start: Color = Color.AQUA
@export var orbit_color_middle: Color = Color.AQUA
@export var orbit_color_end: Color = Color.AQUA

@export var collision_shape: CollisionShape2D
@export var satellite_of: Node2D
@export var default_soi_line_width: float = 15.0
@export var rotation_speed: float = 0.5
var soi_line_width: float = 15.0
var soi_radius: float

func _ready() -> void:
	add_to_group("planets")
	soi_line_width = default_soi_line_width
	
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius
	queue_redraw()
	
	if satellite_of:
		var distance = global_position.distance_to(satellite_of.global_position)
		soi_radius = _calculate_sphere_influence(mass, satellite_of.mass,  distance)
	else:
		soi_radius = INF 

func _physics_process(_delta: float) -> void:
	rotation += rotation_speed * _delta
	constant_angular_velocity = rotation_speed

func _draw() -> void:
	var points = PackedVector2Array()
	var uvs = PackedVector2Array()
	var quality = 220
	
	for i in range(quality):
		var angle = (i * TAU) / quality
		
		var direction = Vector2(cos(angle), sin(angle))
		
		# para deixar o centro do circulo como 0.5 no uv map
		var uv = (direction + Vector2.ONE) / 2.0

		points.append(direction * radius)
		uvs.append(uv)
			
	draw_polygon(points, PackedColorArray([color]), uvs)
	
	if soi_radius != INF:
		var dash_count = 40
		var angle_step = TAU / dash_count
		
		var soi_color = orbit_color_start
		soi_color.a = 0.5
		
		for i in range(dash_count):
			var start_angle = i * angle_step
			var end_angle = start_angle + (angle_step * 0.5) 
			draw_arc(Vector2.ZERO, soi_radius, start_angle, end_angle, 4, soi_color, soi_line_width)
		
		
func _calculate_sphere_influence(satellite_mass, planet_mass, distance) -> float:
		# r = D * (m/M) ^ 2/5
		return distance * pow(satellite_mass/planet_mass, 0.4) 
	
