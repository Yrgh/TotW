extends TabContainer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Global.update_vars()
	var space = Vector2(Global.ScreenSize)
	size.x = .625  * space.x
	size.y = .875 * space.y
	position = space*.5 - size*.5
