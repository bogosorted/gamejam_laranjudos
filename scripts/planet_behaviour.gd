extends StaticBody2D

@export var mass: float = 500.0
@export var radius: float = 3565.0
@export var color: Color = Color.WHITE
@export var collision_shape: CollisionShape2D

func _ready() -> void:
	add_to_group("planets")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius
	queue_redraw()
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
