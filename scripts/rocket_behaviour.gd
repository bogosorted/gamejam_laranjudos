extends RigidBody2D

@export var thrust_force: float = 40000.0
@export var rotation_speed: float = 500.0
@export var engine_offset_y: float = 32.0 
@export var sas_strength: float = 5000.0
@export var particle_2D: GPUParticles2D
@export var sprite_2D_engine: Sprite2D
var motor_heat : float = 0.0

func _physics_process(delta: float) -> void:
	var rotation_dir = Input.get_axis("move_left", "move_right")

	if rotation_dir != 0:
		constant_torque = rotation_dir * rotation_speed * 1000.0
	else:
		constant_torque = -angular_velocity * sas_strength * 1000.0

	if Input.is_action_pressed("move_up"):
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
