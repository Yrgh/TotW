extends Node

var stamina = 100.0
var staminaOut = false

var walkTime = 0

@onready var ScreenSize = get_window().get_size()

var StaminaBarPad
@onready var StaminaBarSize

func update_vars():
	ScreenSize = get_window().get_size()
	StaminaBarSize = Vector2(3*ScreenSize.x/30,ScreenSize.x/30)
	StaminaBarPad = Vector2(ScreenSize.x/175,ScreenSize.x/175)
