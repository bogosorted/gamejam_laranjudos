extends CanvasLayer

@export var text_label: Label
@export var portrait: TextureRect
@export var option_1: Label
@export var option_2: Label

var dialog_pages: Array = []
var current_page: int = 0
var has_options: bool = false
var callback_target: Object = null
var callback_func: String = ""
var z_was_pressed: bool = false
var showing_options: bool = false
var selected_option: int = 1
var raw_opt1: String = ""
var raw_opt2: String = ""

var x_was_pressed: bool = false

func _ready():
	add_to_group("dialog")
	visible = false

func start_dialog(pages: Array, image: Texture2D, opt1: String, opt2: String, target: Object, func_name: String):
	dialog_pages = pages
	current_page = 0
	has_options = (opt1 != "" or opt2 != "")
	callback_target = target
	callback_func = func_name
	portrait.texture = image
	
	raw_opt1 = opt1
	raw_opt2 = opt2
	
	option_1.visible = false
	option_2.visible = false
	showing_options = false
	selected_option = 1
	
	show_page()
	visible = true
	z_was_pressed = true
	x_was_pressed = true

func show_page():
	text_label.text = dialog_pages[current_page]
	
	if current_page == dialog_pages.size() - 1 and has_options:
		showing_options = true
		if raw_opt1 != "": option_1.visible = true
		if raw_opt2 != "": option_2.visible = true
		update_option_visuals()
	
func _process(delta: float):
	if not visible: return
	
	var z_is_pressed = Input.is_physical_key_pressed(KEY_Z)
	var x_is_pressed = Input.is_physical_key_pressed(KEY_X)
	
	if x_is_pressed and not x_was_pressed:
		finish_dialog(0)
		return
	x_was_pressed = x_is_pressed
	
	if showing_options:
		if (Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down")) and raw_opt2 != "":
			selected_option = 2 if selected_option == 1 else 1
			update_option_visuals()
			
		if z_is_pressed and not z_was_pressed:
			finish_dialog(selected_option)
	else:
		if z_is_pressed and not z_was_pressed:
			if current_page < dialog_pages.size() - 1:
				current_page += 1
				show_page()
			else:
				finish_dialog(-1)
					
	z_was_pressed = z_is_pressed

func update_option_visuals():
	if selected_option == 1:
		option_1.text = "> " + raw_opt1 if raw_opt1 != "" else ""
		option_2.text = "  " + raw_opt2 if raw_opt2 != "" else ""
	else:
		option_1.text = "  " + raw_opt1 if raw_opt1 != "" else ""
		option_2.text = "> " + raw_opt2 if raw_opt2 != "" else ""

func finish_dialog(choice: int):
	visible = false
	if callback_target and callback_target.has_method(callback_func):
		callback_target.call(callback_func, choice)
