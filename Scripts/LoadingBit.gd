extends ColorRect

var time = 0

func _ready() -> void:
	time = 0
	size = Vector2(1000000,1000000)

func _process(delta: float) -> void:
	if time > 3:
		size = Vector2(0,0)
	else:
		time += 1
	
