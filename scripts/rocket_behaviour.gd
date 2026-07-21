extends RigidBody2D

@export var thrust_force: float = 40000.0
@export var rotation_speed: float = 500.0
@export var engine_offset_y: float = 32.0 
@export var sas_strength: float = 5000.0
@export var particle_2D: GPUParticles2D
@export var sprite_2D_engine: Sprite2D
@export var gravity_resolver: Node
@onready var enter_sound = $EnterSound
@onready var engine_sound = $EngineSound
@onready var walk_sound = $WalkSound

@export var label_enter: Label

var motor_heat : float = 0.0
var is_landed: bool = false
var player_inside: bool = false
var astronaut: Node2D = null
var current_angle: float = 0.0
var walk_speed: float = 1.0
var e_was_pressed: bool = false

func _ready() -> void:
	await get_tree().process_frame
	
	var closest_planet = gravity_resolver.planet_with_gravity_influence
	if closest_planet:
		current_angle = -PI / 2.0
	else:
		current_angle = 0.0
		
	astronaut = preload("res://astronaut.tscn").instantiate()
	get_parent().add_child(astronaut)
		
	var cam = get_viewport().get_camera_2d()
	if cam: cam.player = astronaut

func _physics_process(delta: float) -> void:
	if label_enter:
		if player_inside:
			if is_landed:
				label_enter.text = "Aperte a tecla E\npara sair"
				label_enter.visible = true
			else:
				label_enter.visible = false
		elif astronaut:
			if astronaut.global_position.distance_to(global_position) < 200.0:
				label_enter.text = "Aperte a tecla E\npara entrar"
				label_enter.visible = true
			else:
				label_enter.visible = false

	var e_is_pressed = Input.is_physical_key_pressed(KEY_E)
	if e_is_pressed and not e_was_pressed:
		if player_inside:
			if is_landed:
				player_inside = false
				enter_sound.play()
				astronaut = preload("res://astronaut.tscn").instantiate()
				get_parent().add_child(astronaut)
				var closest_planet = gravity_resolver.planet_with_gravity_influence
				current_angle = closest_planet.global_position.angle_to_point(global_position)
				
				var cam = get_viewport().get_camera_2d()
				if cam: cam.player = astronaut
			
		elif not player_inside and astronaut:
			if astronaut.global_position.distance_to(global_position) < 200.0:
				player_inside = true
				enter_sound.play()
				print("bora")
				
				var cam = get_viewport().get_camera_2d()
				if cam: cam.player = self
				
				astronaut.queue_free()
				astronaut = null
	e_was_pressed = e_is_pressed

	if not player_inside and astronaut:
		constant_torque = 0.0
		var closest_planet = gravity_resolver.planet_with_gravity_influence
		var walk_dir = Input.get_axis("move_left", "move_right")
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
				if not walk_sound.playing:
					walk_sound.play()
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

	if Input.is_action_pressed("move_up"):
		if not engine_sound.playing:
			engine_sound.play()
		
		particle_2D.emitting = true
		var forward_direction = Vector2.UP.rotated(rotation)
		var engine_position = Vector2(0, engine_offset_y).rotated(rotation)
		apply_force(forward_direction * thrust_force, engine_position)
		motor_heat = clamp(motor_heat + delta *3, 0.0, 1.0)
		sprite_2D_engine.material.set_shader_parameter("intensity", motor_heat)
	else:
		particle_2D.emitting = false
		if engine_sound.playing:
			engine_sound.stop()
		
		motor_heat = clamp(motor_heat - delta *3, 0.0, 1.0)
		sprite_2D_engine.material.set_shader_parameter("intensity", motor_heat)
	calculate_is_landed()
	
func calculate_is_landed() -> void:
	var closest_planet = gravity_resolver.planet_with_gravity_influence
	var distance = global_position.distance_to(closest_planet.global_position)
	var altitude = (distance - closest_planet.radius - 47)/10 #tamanho da nave
	var velocity = linear_velocity.length() / 100.0
	
	var planet_angle = closest_planet.global_position.angle_to_point(global_position)
	var expected_rotation = planet_angle + (PI / 2.0)
	var angle_diff = rad_to_deg(abs(angle_difference(rotation, expected_rotation)))
	
	if velocity <= 5 and altitude <= 25 and angle_diff <= 3.0:
		is_landed = true
	else:
		is_landed = false
