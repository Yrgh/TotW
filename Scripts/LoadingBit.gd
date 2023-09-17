extends ColorRect

var time = 0
var frames = 0

func _ready() -> void:
	time = 0
	frames = 0
	size = Vector2(1000000,1000000)

func _process(delta: float) -> void:
	if time > 0.1 && frames > 10:
		size = Vector2(0,0)
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		time += delta
		frames += 1
	
