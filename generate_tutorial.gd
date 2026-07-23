extends SceneTree

func _init():
	var script = load("res://scripts/dialog_node.gd")
	
	var node_start = script.new()
	node_start.is_entry_checker = true
	
	var node_no_mission = script.new()
	node_no_mission.lines = ["", ""]
	node_no_mission.option_1 = ""
	node_no_mission.option_2 = ""
	
	var node_accept = script.new()
	node_accept.lines = ["", ""]
	node_accept.option_1 = ""
	node_accept.action_give_mission_type = "altitude"
	node_accept.action_give_mission_value = 700.0
	
	var node_decline = script.new()
	node_decline.lines = [""]
	node_decline.option_1 = ""
	
	node_no_mission.next_node_1 = node_accept
	node_no_mission.next_node_2 = node_decline
	
	var node_incomplete = script.new()
	node_incomplete.lines = ["", ""]
	node_incomplete.option_1 = ""
	
	var node_complete = script.new()
	node_complete.lines = ["", ""]
	node_complete.option_1 = "Thanks"
	node_complete.action_complete_mission_and_reward = true
	node_complete.is_one_time_mission = true
	node_complete.reward_variable = "cheeses"
	node_complete.reward_amount = 1
	
	var node_already_done = script.new()
	node_already_done.lines = ["", ""]
	node_already_done.option_1 = ""
	
	node_start.node_if_no_mission = node_no_mission
	node_start.node_if_mission_incomplete = node_incomplete
	node_start.node_if_mission_complete = node_complete
	node_start.node_if_already_completed = node_already_done
	
	ResourceSaver.save(node_start, "res://tutorial_dialog.tres")
	print("DONE GENERATING")
	quit()
