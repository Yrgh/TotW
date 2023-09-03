extends Button
class_name ControlUpdr

var eventAction : String
var code : int
var isMouse : bool

var open := false

var mouse_over := false

const MOUSE_NAMES = ["???","MOUSE1","MOUSE2","MOUSE3","SCROLLWHEEL UP","SCROLLWHEEL DOWN","???","???","???","???"]

func _ready() -> void:
	open = false
	button_pressed = false



func _process(_delta: float) -> void:
	if button_pressed:
		open = true
	
	if open:
		text = "<Press Key>"
	else:
		if isMouse:
			text = "["+MOUSE_NAMES[code]+"]"
		else:
			text = "["+OS.get_keycode_string(code).to_upper()+"]"

func _input(event: InputEvent) -> void:
	if open:
		if event is InputEventKey:
			InputMap.action_erase_events(eventAction)
			open = false
			InputMap.action_add_event(eventAction,event)
			code = event.keycode
			isMouse = false
		elif event is InputEventMouseButton:
			if !event.pressed:
				return
			
			InputMap.action_erase_events(eventAction)
			open = false
			InputMap.action_add_event(eventAction,event)
			code = event.button_index
			isMouse = true

func loaded(key:String) -> void:
	InputMap.action_erase_events(eventAction)
	code = str_to_var(key)
	
	var event : InputEvent
	if isMouse:
		event = InputEventMouseButton.new()
		event.button_index = code
		event.pressed = true
	else:
		event = InputEventKey.new()
		event.keycode = code
	
	InputMap.action_add_event(eventAction,event)
