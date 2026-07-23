extends Area2D

@export var dialog_box: CanvasLayer
@export var shop_image: Texture2D

@export_category("Textos da Loja")
@export var text_a_offer: Array[String] = ["Olá! Quer trocar 1 queijo por 15 de gasolina?"]
@export var option_yes: String = "Sim"
@export var option_no: String = "Não"

@export var text_b_success: Array[String] = ["Negócio fechado! Tanque abastecido."]
@export var text_c_failure: Array[String] = ["Você tá liso em amigo?"]

var player_in_range: bool = false
var z_was_pressed: bool = false
var interaction_cooldown: float = 0.0

var current_state: int = 0

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
		current_state = 0

func _process(delta: float):
	if interaction_cooldown > 0.0:
		interaction_cooldown -= delta * 16.0
		
	var z_is_pressed = Input.is_physical_key_pressed(KEY_Z)
	
	if player_in_range and z_is_pressed and not z_was_pressed and interaction_cooldown <= 0.0:
		if dialog_box and not dialog_box.visible:
			if current_state == 0:
				dialog_box.start_dialog(text_a_offer, shop_image, option_yes, option_no, self, "on_offer_closed")
			else:
				current_state = 0
				dialog_box.start_dialog(text_a_offer, shop_image, option_yes, option_no, self, "on_offer_closed")

	z_was_pressed = z_is_pressed

func on_offer_closed(choice: int):
	if choice == 1:
		if Global.cheeses >= 1:
			Global.cheeses -= 1
			var rocket = get_tree().get_first_node_in_group("rocket")
			if rocket:
				rocket.max_fuel += 15.0
				rocket.current_fuel += 15.0
			current_state = 1
			dialog_box.start_dialog(text_b_success, shop_image, "Ok", "", self, "on_result_closed")
		else:
			current_state = 1
			dialog_box.start_dialog(text_c_failure, shop_image, "Ok", "", self, "on_result_closed")
	else:
		current_state = 1
		dialog_box.start_dialog(text_c_failure, shop_image, "Ok", "", self, "on_result_closed")

func on_result_closed(choice: int):
	interaction_cooldown = 0.1
