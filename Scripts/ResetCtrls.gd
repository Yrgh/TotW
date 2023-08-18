extends Button


@onready var container := $'..'

func _pressed() -> void:
	container.reset()
