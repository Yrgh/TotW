extends Button
class_name ControlUpdr

var eventAction : String
var keyName : String

var open := false

func _process(_delta: float) -> void:
	if button_pressed:
		open = true
	if open:
		text = "<Press Key>"
	else:
		text = "["+keyName+"]"

func _input(event: InputEvent) -> void:
	if event is InputEventKey && open:
		InputMap.action_erase_events(eventAction)
		open = false
		InputMap.action_add_event(eventAction,event)
		keyName = event.as_text_keycode().to_upper()
