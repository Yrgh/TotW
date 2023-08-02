extends ColorRect

@onready var staticPiece := $"../Static"
@onready var backPiece := $"../Back"
@onready var main := $".."

const goodColor := Color(0.2,0.85,0.1)
const badColor := Color(.94,.34,0)

func before():
	Global.update_vars()
	backPiece.color = Color(0,0,0)
	backPiece.size = 2*Global.StaminaBarPad + Vector2(Global.StaminaBarSize.x*2,Global.StaminaBarSize.y)
	staticPiece.size = Global.StaminaBarSize
	staticPiece.position = Global.StaminaBarPad
	size = Global.StaminaBarSize
	position.y = Global.StaminaBarPad.y
	main.position.x = Global.ScreenSize.x*.85 - int(Global.StaminaBarSize.x)
	main.position.y = Global.ScreenSize.y - 1.5*int(Global.StaminaBarSize.y)
	main.position -= Global.StaminaBarPad


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	before()
	
	if Global.stamina < 0:
		Global.staminaOut = true
		Global.stamina = 0
	elif Global.stamina > 99:
		Global.staminaOut = false
	
	var sv = Global.stamina / 100
	position.x = Global.StaminaBarPad.x + Global.StaminaBarSize.x * (2*sv-1)
	
	if Global.staminaOut:
		color = badColor
		staticPiece.color = badColor
	else:
		color = goodColor
		staticPiece.color = goodColor
	
	if sv<.5:
		color = Color(0,0,0)
		position.x += Global.StaminaBarSize.x
