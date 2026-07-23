extends CanvasLayer

@export var arrow_texture: Texture2D
@export var distance_from_center: float = 0.25
@export var rotation_offset_degrees: float = 90.0
@export var arrow_scale: float = 0.7

var arrow_sprite: Sprite2D
var active_target: Node2D

func _ready():
	layer = 100
	arrow_sprite = Sprite2D.new()
	if arrow_texture:
		arrow_sprite.texture = arrow_texture
	add_child(arrow_sprite)

func _process(delta):
	var cam = get_viewport().get_camera_2d()
	if not cam:
		if arrow_sprite: arrow_sprite.visible = false
		return
		
	active_target = null
	
	if Global.active_mission_completed:
		if is_instance_valid(Global.last_mission_npc):
			active_target = Global.last_mission_npc
	elif Global.active_mission_type != "":
		if Global.active_mission_type in ["reach_planet", "orbit"]:
			var planets = get_tree().get_nodes_in_group("planet")
			for p in planets:
				if "planet_name" in p and p.planet_name == Global.active_mission_target:
					active_target = p
					break
		elif Global.active_mission_type == "altitude":
			pass
	else:
		var npcs = get_tree().get_nodes_in_group("npc")
		var closest = null
		var dist = 99999999.0
		var player_pos = cam.global_position
		for n in npcs:
			if "mission_permanently_completed" in n and not n.mission_permanently_completed:
				var d = n.global_position.distance_to(player_pos)
				if d < dist:
					dist = d
					closest = n
		active_target = closest

	if active_target:
		var screen_center = get_viewport().get_visible_rect().size / 2.0
		var target_screen_pos = active_target.get_global_transform_with_canvas().origin
		
		arrow_sprite.visible = true
		var dir = (target_screen_pos - screen_center).normalized()
		var radius = min(screen_center.x, screen_center.y) * distance_from_center
		arrow_sprite.position = screen_center + dir * radius
		arrow_sprite.rotation = dir.angle() + deg_to_rad(rotation_offset_degrees)
		arrow_sprite.scale = Vector2(arrow_scale, arrow_scale)
	else:
		arrow_sprite.visible = false
