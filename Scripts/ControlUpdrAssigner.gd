extends GridContainer

@onready var parent := $'..'

@onready var jump := $JumpKey
@onready var forward := $ForwardKey
@onready var back := $BackKey
@onready var left := $LeftKey
@onready var right := $RightKey
@onready var focus_hold := $FocusHoldKey
@onready var focus_toggle := $FocusToggleKey
@onready var item := $ItemKey
@onready var sprint := $SprintKey
@onready var zoom_in := $ZoomInKey
@onready var zoom_out := $ZoomOutKey
@onready var inven := $InvenKey

@onready var show_perf := $ShowPerfButton
@onready var debug_window := $DebugWindowToggle
@onready var vfx := $VFXToggle

@onready var destination_text := $Destination

func set_eventActions() -> void:
	jump.eventAction = "jump"
	forward.eventAction = "forward"
	back.eventAction = "backward"
	left.eventAction = "left"
	right.eventAction = "right"
	focus_hold.eventAction = "focus(hold)"
	focus_toggle.eventAction = "focus(toggle)"
	item.eventAction = "item"
	sprint.eventAction = "sprint"
	zoom_in.eventAction = "zoom_in"
	zoom_out.eventAction = "zoom_out"
	inven.eventAction = "inven"

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
	zoom_in.code = 4
	zoom_out.code = 5
	inven.code = KEY_E
	
	jump.isMouse = false
	forward.isMouse = false
	back.isMouse = false
	left.isMouse = false
	right.isMouse = false
	item.isMouse = false
	focus_hold.isMouse = false
	focus_toggle.isMouse = false
	sprint.isMouse = false
	zoom_in.isMouse = true
	zoom_out.isMouse = true
	inven.isMouse = false
	
	show_perf.button_pressed = false
	debug_window.button_pressed = false
	vfx.button_pressed = true

var destination := "Controls"
func _ready() -> void:
	if FileAccess.file_exists("user://LAST_CONTROLS_DESTINATION.txt"):
		destination = FileAccess.open("user://LAST_CONTROLS_DESTINATION.txt",FileAccess.READ).get_line()
	
	destination_text.text = destination
	
	load_data()
	
	set_eventActions()
	
func save():
	set_eventActions()
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
	save_keybind(save_file,"zoom_in",zoom_in)
	save_keybind(save_file,"zoom_out",zoom_out)
	save_keybind(save_file,"inven",inven)
	
	save_data(save_file,"show_perf",show_perf.button_pressed)
	save_data(save_file,"debug_window",debug_window.button_pressed)
	save_data(save_file,"vfx",vfx.button_pressed)
	

func save_keybind(save_file,typename:String,node):
	save_file.store_line("#"+typename+"#")
	save_file.store_line(str(node.isMouse)) 
	save_file.store_line(str(node.code))

func save_data(save_file,typename:String,val):
	save_file.store_line("$"+typename+"$")
	save_file.store_line(str(val))

func load_data():
	set_eventActions()
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
			"zoom_in":
				zoom_in.isMouse = str_to_var(data)
			"zoom_out":
				zoom_out.isMouse = str_to_var(data)
			"inven":
				inven.isMouse = str_to_var(data)
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
			"zoom_in":
				zoom_in.loaded(data)
			"zoom_out":
				zoom_out.loaded(data)
			"inven":
				inven.loaded(data)
	else:
		print("ERROR loading code")

func set_toggleData(var_name,data):
	match var_name:
		"show_perf":
			show_perf.button_pressed = str_to_var(data)
		"debug_window":
			debug_window.button_pressed = str_to_var(data)
		"vfx":
			vfx.button_pressed = str_to_var(data)
	
