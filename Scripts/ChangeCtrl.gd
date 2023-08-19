extends Button
class_name ControlUpdr

var eventAction : String
var keyName : int

var open := false

func _process(_delta: float) -> void:
	if button_pressed:
		open = true
	if open:
		text = "<Press Key>"
	else:
		text = "["+OS.get_keycode_string(keyName).to_upper()+"]"

func _input(event: InputEvent) -> void:
	if event is InputEventKey && open:
		InputMap.action_erase_events(eventAction)
		open = false
		InputMap.action_add_event(eventAction,event)
		keyName = event.keycode

func loaded(key:String) -> void:
	InputMap.action_erase_events(eventAction)
	var event = InputEventKey.new()
	event.keycode = str_to_var(key)
	keyName = str_to_var(key)
	InputMap.action_add_event(eventAction,event)
