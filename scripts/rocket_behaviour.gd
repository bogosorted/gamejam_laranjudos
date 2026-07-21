extends RigidBody2D

@export var thrust_force: float = 40000.0
@export var rotation_speed: float = 500.0
@export var engine_offset_y: float = 32.0 
@export var sas_strength: float = 5000.0
@export var particle_2D: GPUParticles2D
@export var sprite_2D_engine: Sprite2D
@export var gravity_resolver: Node

@export var label_enter: Label
@export var label_planet_name: Label
@export var label_velocity: Label
@export var label_altitude: Label
@export var label_gasoline: Label
@export var label_cheeses: Label
@export var label_mission: Label

var motor_heat : float = 0.0
var max_fuel: float = 25.0
var current_fuel: float = 25.0
var is_landed: bool = false
var player_inside: bool = false
var astronaut: Node2D = null
var current_angle: float = 0.0
var walk_speed: float = 1.0
var e_was_pressed: bool = false
var last_safe_planet: Node2D = null

func _ready() -> void:
	await get_tree().process_frame
	
	var closest_planet = gravity_resolver.planet_with_gravity_influence
	if closest_planet:
		current_angle = -PI / 2.0
	else:
		current_angle = 0.0
		
	astronaut = preload("res://astronaut.tscn").instantiate()
	get_parent().add_child(astronaut)
	add_collision_exception_with(astronaut)
		
	var cam = get_viewport().get_camera_2d()
	if cam: cam.player = astronaut

func _physics_process(delta: float) -> void:
	var in_dialog = false
	var dialog = get_tree().get_first_node_in_group("dialog")
	if dialog and dialog.visible:
		in_dialog = true
		
	var near_npc = false
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.player_in_range:
			near_npc = true
			break
			
	if label_enter:
		if in_dialog:
			label_enter.visible = false
		elif player_inside:
			if is_landed:
				label_enter.text = "Aperte a tecla E\npara sair"
				label_enter.visible = true
			else:
				label_enter.visible = false
		elif near_npc:
			label_enter.text = "Aperte Z\npara conversar"
			label_enter.visible = true
		elif astronaut:
			if astronaut.global_position.distance_to(global_position) < 200.0:
				label_enter.text = "Aperte a tecla E\npara entrar"
				label_enter.visible = true
			else:
				label_enter.visible = false

	if player_inside:
		if label_velocity: label_velocity.visible = true
		if label_altitude: label_altitude.visible = true
		if label_gasoline:
			label_gasoline.visible = true
			label_gasoline.text = "GAS: %d/%d" % [int(current_fuel), int(max_fuel)]
		if label_planet_name:
			var closest_planet = gravity_resolver.planet_with_gravity_influence
			if closest_planet:
				label_planet_name.text = closest_planet.planet_name
				label_planet_name.modulate = closest_planet.orbit_color_start
				label_planet_name.visible = true
			else:
				label_planet_name.visible = false
	else:
		if label_velocity: label_velocity.visible = false
		if label_altitude: label_altitude.visible = false
		if label_gasoline: label_gasoline.visible = false
		if label_planet_name: label_planet_name.visible = false

	if label_cheeses:
		label_cheeses.visible = true
		label_cheeses.text = str(Global.cheeses)

	if label_mission:
		if Global.active_mission_type == "" or Global.active_mission_type == "none":
			label_mission.visible = false
		else:
			label_mission.visible = true
			if Global.active_mission_completed:
				label_mission.text = "MISSÃO COMPLETA! Volte ao robô."
			else:
				if Global.active_mission_type == "reach_planet":
					label_mission.text = "Pouse em " + Global.active_mission_target
				elif Global.active_mission_type == "orbit":
					label_mission.text = "Orbite " + Global.active_mission_target
				elif Global.active_mission_type == "altitude":
					label_mission.text = "Alcance " + str(Global.active_mission_value) + "m de altitude"

	var e_is_pressed = Input.is_physical_key_pressed(KEY_E)
	if e_is_pressed and not e_was_pressed and not in_dialog:
		if player_inside:
			if is_landed:
				player_inside = false
				astronaut = preload("res://astronaut.tscn").instantiate()
				get_parent().add_child(astronaut)
				add_collision_exception_with(astronaut)
				var closest_planet = gravity_resolver.planet_with_gravity_influence
				last_safe_planet = closest_planet
				current_angle = closest_planet.global_position.angle_to_point(global_position)
				
				var cam = get_viewport().get_camera_2d()
				if cam: cam.player = astronaut
			
		elif not player_inside and astronaut and not near_npc:
			if astronaut.global_position.distance_to(global_position) < 200.0:
				player_inside = true
				print("bora")
				
				var cam = get_viewport().get_camera_2d()
				if cam: cam.player = self
				
				astronaut.queue_free()
				astronaut = null
	e_was_pressed = e_is_pressed
	
	if Input.is_physical_key_pressed(KEY_R):
		var target_planet = last_safe_planet
		if not target_planet:
			target_planet = gravity_resolver.planet_with_gravity_influence
		
		if target_planet:
			linear_velocity = Vector2.ZERO
			angular_velocity = 0.0
			motor_heat = 0.0
			current_fuel = max_fuel
			
			if not player_inside and astronaut:
				astronaut.queue_free()
				astronaut = null
				player_inside = true
				var cam = get_viewport().get_camera_2d()
				if cam: cam.player = self
				
			var spawn_distance = target_planet.radius + 190.0
			global_position = target_planet.global_position + Vector2(0, -spawn_distance)
			rotation = 0.0

	if not player_inside and astronaut:
		constant_torque = 0.0
		var closest_planet = gravity_resolver.planet_with_gravity_influence
		var walk_dir = 0
		if not in_dialog:
			walk_dir = Input.get_axis("move_left", "move_right")
		current_angle += walk_dir * walk_speed * delta
		var distance_from_center = closest_planet.radius + 30
		var x = cos(current_angle) * distance_from_center
		var y = sin(current_angle) * distance_from_center
		astronaut.global_position = closest_planet.global_position + Vector2(x, y)
		astronaut.rotation = current_angle + (PI / 2.0)
		
		var anim_sprite = astronaut.get_node("AnimatedSprite2D")
		if walk_dir != 0:
			if anim_sprite.animation != "walking" or not anim_sprite.is_playing():
				anim_sprite.play("walking")
			anim_sprite.flip_h = (walk_dir < 0)
		else:
			if anim_sprite.animation != "idle" or not anim_sprite.is_playing():
				anim_sprite.play("idle")
			
		particle_2D.emitting = false
		motor_heat = clamp(motor_heat - delta *3, 0.0, 1.0)
		sprite_2D_engine.material.set_shader_parameter("intensity", motor_heat)
		calculate_is_landed()
		return

	var rotation_dir = Input.get_axis("move_left", "move_right")

	if rotation_dir != 0:
		constant_torque = rotation_dir * rotation_speed * 1000.0
	else:
		constant_torque = -angular_velocity * sas_strength * 1000.0

	if Input.is_action_pressed("move_up") and current_fuel > 0.0:
		current_fuel = max(0.0, current_fuel - delta * 20.0)
		particle_2D.emitting = true
		var forward_direction = Vector2.UP.rotated(rotation)
		var engine_position = Vector2(0, engine_offset_y).rotated(rotation)
		apply_force(forward_direction * thrust_force, engine_position)
		motor_heat = clamp(motor_heat + delta *3, 0.0, 1.0)
		sprite_2D_engine.material.set_shader_parameter("intensity", motor_heat)
	else:
		particle_2D.emitting = false
		motor_heat = clamp(motor_heat - delta *3, 0.0, 1.0)
		sprite_2D_engine.material.set_shader_parameter("intensity", motor_heat)
	calculate_is_landed()
	
	if Global.active_mission_type != "" and not Global.active_mission_completed:
		var cp = gravity_resolver.planet_with_gravity_influence
		if cp:
			if Global.active_mission_type == "reach_planet" and cp.planet_name == Global.active_mission_target:
				if is_landed:
					Global.active_mission_completed = true
			elif Global.active_mission_type == "orbit" and cp.planet_name == Global.active_mission_target:
				var dist = global_position.distance_to(cp.global_position)
				var alt = (dist - cp.radius - 47)/10
				if alt > 50 and alt < 500 and linear_velocity.length() > 200:
					Global.active_mission_completed = true
			elif Global.active_mission_type == "altitude":
				var dist = global_position.distance_to(cp.global_position)
				var alt = max(0, ((dist - cp.radius - 47)/10) - 13.5)
				if alt >= Global.active_mission_value:
					Global.active_mission_completed = true
	
func calculate_is_landed() -> void:
	var closest_planet = gravity_resolver.planet_with_gravity_influence
	var distance = global_position.distance_to(closest_planet.global_position)
	var altitude = (distance - closest_planet.radius - 47)/10 #tamanho da nave
	var velocity = linear_velocity.length() / 100.0
	
	if label_velocity:
		label_velocity.text = "V: %d m/s" % int(velocity)
	if label_altitude:
		var display_alt = max(0, altitude - 13.5)
		label_altitude.text = "A: %d m" % int(display_alt)
	
	var planet_angle = closest_planet.global_position.angle_to_point(global_position)
	var expected_rotation = planet_angle + (PI / 2.0)
	var angle_diff = rad_to_deg(abs(angle_difference(rotation, expected_rotation)))
	
	if velocity <= 5 and altitude <= 25 and angle_diff <= 3.0:
		is_landed = true
	else:
		is_landed = false
