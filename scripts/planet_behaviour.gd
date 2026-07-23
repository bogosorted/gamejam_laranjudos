@tool
extends StaticBody2D

@export var mass: float = 500.0
@export var radius: float = 3565.0:
	set(value):
		radius = value
		queue_redraw()
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()
@export var planet_name: String = "Planeta"

@export var orbit_color_start: Color = Color.AQUA
@export var orbit_color_middle: Color = Color.AQUA
@export var orbit_color_end: Color = Color.AQUA
@export var is_sun: bool = false

@export var collision_shape: CollisionShape2D
@export var satellite_of: Node2D
@export var default_soi_line_width: float = 15.0
@export var rotation_speed: float = 0.5
var soi_line_width: float = 15.0
var soi_radius: float
var soi_visualizer: Node2D

func _ready() -> void:
	if Engine.is_editor_hint():
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = radius
		queue_redraw()
		return
		
	add_to_group("planets")
	soi_line_width = default_soi_line_width
	
	soi_visualizer = Node2D.new()
	soi_visualizer.set_script(preload("res://scripts/soi_visualizer.gd"))
	soi_visualizer.parent_planet = self
	soi_visualizer.use_parent_material = false
	soi_visualizer.z_index = -2
	add_child(soi_visualizer)
	
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius
	queue_redraw()
	
	if satellite_of:
		var distance = global_position.distance_to(satellite_of.global_position)
		soi_radius = _calculate_sphere_influence(mass, satellite_of.mass,  distance)
	else:
		soi_radius = INF 

func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		rotation += rotation_speed * _delta
		constant_angular_velocity = rotation_speed

func _draw() -> void:
	var points = PackedVector2Array()
	var uvs = PackedVector2Array()
	var quality = 220
	
	for i in range(quality):
		var angle = (i * TAU) / quality
		
		var direction = Vector2(cos(angle), sin(angle))
		
		var uv = (direction + Vector2.ONE) / 2.0

		points.append(direction * radius)
		uvs.append(uv)
			
	draw_polygon(points, PackedColorArray([color]), uvs)
	
	if soi_visualizer:
		soi_visualizer.queue_redraw()
		
func _calculate_sphere_influence(satellite_mass, planet_mass, distance) -> float:
		return distance * pow(satellite_mass/planet_mass, 0.4) 
	
