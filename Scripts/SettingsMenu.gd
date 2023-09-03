extends Control

@onready var main = $MarginContainer
@onready var menu = $'..'

func _process(delta: float) -> void:
	main.size = menu.size
