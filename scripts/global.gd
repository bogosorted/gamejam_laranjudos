extends Node

var cheeses: int = 0
var active_mission_type: String = ""
var active_mission_target: String = ""
var active_mission_value: float = 0.0
var active_mission_completed: bool = false
var last_mission_npc: Node2D = null

var active_mission_auto_complete: bool = false
var active_mission_reward_variable: String = ""
var active_mission_reward_amount: int = 0
