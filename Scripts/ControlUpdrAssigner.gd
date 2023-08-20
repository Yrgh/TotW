extends GridContainer


@onready var jump := $JumpKey
@onready var forward := $ForwardKey
@onready var back := $BackKey
@onready var left := $LeftKey
@onready var right := $RightKey
@onready var focus_hold := $FocusHoldKey
@onready var focus_toggle := $FocusToggleKey
@onready var item := $ItemKey
@onready var sprint := $SprintKey

@onready var show_perf := $ShowPerfButton
@onready var debug_window := $DebugWindowToggle

@onready var destination_text := $Destination

func reset() -> void:
	jump.code = KEY_SPACE
	forward.code = KEY_W
	back.code = KEY_S
	left.code = KEY_A
	right.code = KEY_D
	focus_hold.code = KEY_C
	focus_toggle.code = KEY_V
	item.code = KEY_Q
	sprint.code = KEY_SHIFT
	
	jump.isMouse = false
	forward.isMouse = false
	back.isMouse = false
	left.isMouse = false
	right.isMouse = false
	item.isMouse = false
	focus_hold.isMouse = false
	focus_toggle.isMouse = false
	sprint.isMouse = false
	
	show_perf.button_pressed = false
	debug_window.button_pressed = false

var destination := "Controls"
func _ready() -> void:
	if FileAccess.file_exists("user://LAST_CONTROLS_DESTINATION.txt"):
		destination = FileAccess.open("user://LAST_CONTROLS_DESTINATION.txt",FileAccess.READ).get_line()
	
	destination_text.text = destination
	
	load_data()
	
	jump.eventAction = "jump"
	forward.eventAction = "forward"
	back.eventAction = "backward"
	left.eventAction = "left"
	right.eventAction = "right"
	focus_hold.eventAction = "focus(hold)"
	focus_toggle.eventAction = "focus(toggle)"
	item.eventAction = "item"
	sprint.eventAction = "sprint"
	
	upd()
	
func save():
	destination = destination_text.text
	FileAccess.open("user://LAST_CONTROLS_DESTINATION.txt",FileAccess.WRITE).store_line(destination)
	
	var save_file := FileAccess.open("user://"+destination+".dat",FileAccess.WRITE)
	
	#Format: #Name
	#        eventAction
	#        keyName
	
	save_keybind(save_file,"jump",jump)
	save_keybind(save_file,"forward",forward)
	save_keybind(save_file,"back",back)
	save_keybind(save_file,"left",left)
	save_keybind(save_file,"right",right)
	save_keybind(save_file,"focus(hold)",focus_hold)
	save_keybind(save_file,"focus(toggle)",focus_toggle)
	save_keybind(save_file,"item",item)
	save_keybind(save_file,"sprint",sprint)
	
	save_data(save_file,"show_perf",show_perf.button_pressed)
	save_data(save_file,"debug_window",debug_window.button_pressed)
	

func save_keybind(save_file,typename:String,node):
	save_file.store_line("#"+typename+"#")
	save_file.store_line(str(node.isMouse)) 
	save_file.store_line(str(node.code))

func save_data(save_file,typename:String,val):
	save_file.store_line("$"+typename+"$")
	save_file.store_line(str(val))

func load_data():
	destination = destination_text.text
	FileAccess.open("user://LAST_CONTROLS_DESTINATION.txt",FileAccess.WRITE).store_line(destination)
	
	if !FileAccess.file_exists("user://"+destination+".dat"):
		reset()
		return
	
	
	var file = FileAccess.open("user://"+destination+".dat",FileAccess.READ)
	var lineType = ""
	var current_var_name
	while file.get_position() < file.get_length():
		var line = file.get_line()
		
		if line.begins_with("#") && line.ends_with("#"):
			current_var_name = line.get_slice("#",1)
			lineType = "isMouse"
		elif line.begins_with("$") && line.ends_with("$"):
			current_var_name = line.get_slice("$",1)
			lineType = "toggleData"
		else:
			if lineType == "isMouse":
				lineType = "keyName"
				set_isMouse(current_var_name,line)
			elif lineType == "keyName":
				set_keyName(current_var_name,line)
			elif lineType == "toggleData":
				set_toggleData(current_var_name,line)

func set_isMouse(var_name,data):
	if str_to_var(data) != null:
		if data == "":
			reset()
			return
		
		match var_name:
			"jump":
				jump.isMouse = str_to_var(data)
			"forward":
				forward.isMouse = str_to_var(data)
			"back":
				back.isMouse = str_to_var(data)
			"left":
				left.isMouse = str_to_var(data)
			"right":
				right.isMouse = str_to_var(data)
			"focus(hold)":
				focus_hold.isMouse = str_to_var(data)
			"focus(toggle)":
				focus_toggle.isMouse = str_to_var(data)
			"item":
				item.isMouse = str_to_var(data)
			"sprint":
				sprint.isMouse = str_to_var(data)
	else:
		print("ERROR loading isMouse")

func set_keyName(var_name,data):
	if str_to_var(data):
		if data == "":
			reset()
			print("reset oh no")
			return
	
		match var_name:
			"jump":
				jump.loaded(data)
			"forward":
				forward.loaded(data)
			"back":
				back.loaded(data)
			"left":
				left.loaded(data)
			"right":
					right.loaded(data)
			"focus(hold)":
				focus_hold.loaded(data)
			"focus(toggle)":
				focus_toggle.loaded(data)
			"sprint":
				sprint.loaded(data)
			"item":
				item.loaded(data)
	else:
		print("ERROR loading code")

func set_toggleData(var_name,data):
	match var_name:
		"show_perf":
			show_perf.button_pressed = str_to_var(data)
		"debug_window":
			debug_window.button_pressed = str_to_var(data)

func _process(_delta: float) -> void:
	upd()

func upd() -> void:
	Global.update_vars()
	if Global.currentSceneLocation == 'res://Scenes/settings_page.tscn':
		var space = Vector2(Global.ScreenSize) - Vector2(50,20)
		$'../../..'.position = -size/2 + space/2
