extends Control


@onready var main = $MarginContainer

func _process(_delta: float) -> void:
	Global.update_vars()
	main.size = Vector2(Global.ScreenSize)
