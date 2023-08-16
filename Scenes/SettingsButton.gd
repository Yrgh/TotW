extends Button


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	
	var padding = Vector2(Global.ScreenSize)/175
	size = Vector2(Global.ScreenSize)/30
	position.y = float(Global.ScreenSize.y)*.5 - size.y*.5
	position.y += size.y + 2 * padding.y
	position.x = float(Global.ScreenSize.x)*.5 - size.x*.5

