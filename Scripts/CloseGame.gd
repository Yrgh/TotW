extends Button


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Global.update_vars()
	if button_pressed:
		get_tree().quit()
	
	size = Vector2(Global.ScreenSize)/30
	position.y = float(Global.ScreenSize.y)*.5 - size.y*.5
	position.x = float(Global.ScreenSize.x)*.5 - size.x*.5
	
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
