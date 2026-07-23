extends Resource
class_name DialogNode

@export var lines: Array[String] = []
@export var option_1: String = ""
@export var next_node_1: DialogNode
@export var option_2: String = ""
@export var next_node_2: DialogNode
@export_group("mission system")
@export var is_entry_checker: bool = false
@export var node_if_no_mission: DialogNode
@export var node_if_mission_incomplete: DialogNode
@export var node_if_mission_complete: DialogNode
@export var node_if_already_completed: DialogNode

@export_category("Action: Give Mission")
@export_enum("none", "reach_planet", "orbit", "altitude") var action_give_mission_type: String = "none"
@export var action_give_mission_target: String = ""
@export var action_give_mission_value: float = 0.0
@export var is_auto_complete_mission: bool = false

@export_category("Action: Complete Mission")
@export var action_complete_mission_and_reward: bool = false
@export var is_one_time_mission: bool = false
@export var reward_variable: String = ""
@export var reward_amount: int = 0
