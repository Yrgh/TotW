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


func reset() -> void:
	jump.eventAction = "jump"
	forward.eventAction = "forward"
	back.eventAction = "backward"
	left.eventAction = "left"
	right.eventAction = "right"
	focus_hold.eventAction = "focus(hold)"
	focus_toggle.eventAction = "focus(toggle)"
	item.eventAction = "item"
	sprint.eventAction = "sprint"
	
	jump.keyName = KEY_SPACE
	forward.keyName = KEY_W
	back.keyName = KEY_S
	left.keyName = KEY_A
	right.keyName = KEY_D
	focus_hold.keyName = KEY_C
	focus_toggle.keyName = KEY_V
	item.keyName = KEY_Q
	sprint.keyName = KEY_SHIFT
	
	show_perf.button_pressed = false

func _ready() -> void:
	load_data("Controls")
	upd()
	
func save(dest:String):
	var save_file := FileAccess.open("user://"+dest+".dat",FileAccess.WRITE)
	
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
	

func save_keybind(save_file,typename:String,node):
	save_file.store_line("#"+typename+"#")
	save_file.store_line(node.eventAction)
	save_file.store_line(str(node.keyName))

func save_data(save_file,typename:String,val):
	save_file.store_line("$"+typename+"$")
	save_file.store_line(str(val))

func load_data(loc:String):
	if !FileAccess.file_exists("user://"+loc+".dat"):
		reset()
		return
	
	
	var file = FileAccess.open("user://"+loc+".dat",FileAccess.READ)
	var lineType = ""
	var current_var_name
	while file.get_position() < file.get_length():
		var line = file.get_line()
		
		if line.begins_with("#") && line.ends_with("#"):
			current_var_name = line.get_slice("#",1)
			lineType = "eventAction"
		elif line.begins_with("$") && line.ends_with("$"):
			current_var_name = line.get_slice("$",1)
			lineType = "toggleData"
		else:
			if lineType == "eventAction":
				lineType = "keyName"
				set_eventAction(current_var_name,line)
			elif lineType == "keyName":
				set_keyName(current_var_name,line)
			elif lineType == "toggleData":
				set_toggleData(current_var_name,line)

func set_eventAction(var_name,data):
	if data == "":
		reset()
		return
	
	match var_name:
		"jump":
			jump.eventAction = data
		"forward":
			forward.eventAction = data
		"back":
			back.eventAction = data
		"left":
			left.eventAction = data
		"right":
			right.eventAction = data
		"focus(hold)":
			focus_hold.eventAction = data
		"focus(toggle)":
			focus_toggle.eventAction = data
		"item":
			item.eventAction = data
		"sprint":
			sprint.eventAction = data

func set_keyName(var_name,data):
	if data == "":
		reset()
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

func set_toggleData(var_name,data):
	match var_name:
		"show_perf":
			show_perf.button_pressed = str_to_var(data)

func _process(_delta: float) -> void:
	upd()

func upd() -> void:
	Global.update_vars()
	if Global.currentSceneLocation == 'res://Scenes/settings_page.tscn':
		var space = Vector2(Global.ScreenSize) - Vector2(50,20)
		$'../../..'.position = -size/2 + space/2
