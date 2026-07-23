extends Area2D

@export var dialog_box: CanvasLayer
@export var npc_image: Texture2D
@export var mission_sequence: Array[DialogNode] = []

var player_in_range: bool = false
var z_was_pressed: bool = false
var interaction_cooldown: float = 0.0
var current_dialog_node: DialogNode
var current_mission_index: int = 0
var mission_permanently_completed: bool = false

func _ready():
	add_to_group("npc")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if "astronaut" in body.name.to_lower():
		player_in_range = true

func _on_body_exited(body: Node2D):
	if "astronaut" in body.name.to_lower():
		player_in_range = false
		current_dialog_node = null

func _process(delta: float):
	if interaction_cooldown > 0.0:
		interaction_cooldown -= delta * 16.0
		
	var z_is_pressed = Input.is_physical_key_pressed(KEY_Z)
	
	if player_in_range and z_is_pressed and not z_was_pressed and interaction_cooldown <= 0.0:
		if dialog_box and not dialog_box.visible:
			if current_dialog_node == null:
				if mission_sequence.size() > 0:
					if current_mission_index < mission_sequence.size():
						current_dialog_node = mission_sequence[current_mission_index]
					else:
						current_dialog_node = mission_sequence[-1]
			
			if current_dialog_node:
				show_current_node()

	z_was_pressed = z_is_pressed

func show_current_node():
	if current_dialog_node:
		if current_dialog_node.is_entry_checker:
			if mission_permanently_completed:
				if current_dialog_node.node_if_already_completed:
					current_dialog_node = current_dialog_node.node_if_already_completed
				else:
					return
			elif Global.active_mission_type == "" or Global.active_mission_type == "none":
				current_dialog_node = current_dialog_node.node_if_no_mission
			elif Global.active_mission_completed:
				current_dialog_node = current_dialog_node.node_if_mission_complete
			else:
				current_dialog_node = current_dialog_node.node_if_mission_incomplete
			
			if current_dialog_node:
				show_current_node()
			return
			
		dialog_box.start_dialog(current_dialog_node.lines, npc_image, current_dialog_node.option_1, current_dialog_node.option_2, self, "on_dialog_closed")

func on_dialog_closed(choice: int):
	if not current_dialog_node:
		return
		
	if current_dialog_node.action_give_mission_type != "none" and current_dialog_node.action_give_mission_type != "":
		Global.active_mission_type = current_dialog_node.action_give_mission_type
		Global.active_mission_target = current_dialog_node.action_give_mission_target
		Global.active_mission_value = current_dialog_node.action_give_mission_value
		Global.active_mission_auto_complete = current_dialog_node.is_auto_complete_mission
		Global.active_mission_reward_variable = current_dialog_node.reward_variable
		Global.active_mission_reward_amount = current_dialog_node.reward_amount
		Global.active_mission_completed = false
		Global.last_mission_npc = self
		
	if current_dialog_node.action_complete_mission_and_reward:
		Global.active_mission_type = ""
		Global.active_mission_completed = false
		if current_dialog_node.reward_variable != "" and current_dialog_node.reward_amount > 0:
			var current_val = Global.get(current_dialog_node.reward_variable)
			if current_val != null:
				Global.set(current_dialog_node.reward_variable, current_val + current_dialog_node.reward_amount)
		if current_dialog_node.is_one_time_mission:
			current_mission_index += 1
			if current_mission_index >= mission_sequence.size():
				mission_permanently_completed = true
		
	if choice == 1 and current_dialog_node.next_node_1:
		current_dialog_node = current_dialog_node.next_node_1
		show_current_node()
		return
	elif choice == 2 and current_dialog_node.next_node_2:
		current_dialog_node = current_dialog_node.next_node_2
		show_current_node()
		return
	elif choice == -1 and current_dialog_node.next_node_1:
		current_dialog_node = current_dialog_node.next_node_1
		show_current_node()
		return
	else:
		current_dialog_node = null
		interaction_cooldown = 0.1
