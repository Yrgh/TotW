extends CheckButton


func _toggled(button_pressed: bool) -> void:
	Global.vfx_shown = button_pressed
