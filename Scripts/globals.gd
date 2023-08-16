extends Node

var stamina = 100.0
var staminaOut = false

const CD_F = 1.5
const CD_ZETA = 0.8
const CD_R = 1.5

var cameraDist = .1
var animCD = BetterAnimation.new(CD_F,CD_ZETA,CD_R,0.1)

var climbLastFrame := false

@onready var ScreenSize = get_window().get_size()

var StaminaBarPad
@onready var StaminaBarSize

var walkTime = 0

var applicableTimeScale = 1
var ATSon = false

const FOV_F = 2.5
const FOV_ZETA = 0.2
const FOV_R = 1.0

var FOV = BetterAnimation.new(CD_F,CD_ZETA,CD_R,80)

var currentScene = null

func _ready() -> void:
	var root = get_tree().root
	currentScene = root.get_child(root.get_child_count() - 1)

func change_scene(path) -> void:
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path) -> void:
	currentScene.free()
	var s = ResourceLoader.load(path)
	currentScene = s.instantiate()
	get_tree().root.add_child(currentScene)
	get_tree().current_scene = currentScene

func update_vars():
	ScreenSize = get_window().get_size()
	StaminaBarSize = Vector2(3*ScreenSize.x/30,ScreenSize.x/30)
	StaminaBarPad = Vector2(ScreenSize.x/175,ScreenSize.x/175)
	
func reset():
	climbLastFrame = false
	staminaOut = false
	stamina = 100.0
	walkTime = 0
	applicableTimeScale = 1
	ATSon = false

class BetterAnimation:
	var xp : float
	var y : float
	var yd : float
	
	var k1 : float
	var k2 : float
	var k3 : float
	
	func _init(f: float,z: float, r: float, x: float):
		k1 = z/(PI*f)
		k2 = 1/((2*PI*f)**2)
		k3 = r * z/(2*PI*f)
		
		xp = x
		y = x
		yd = 0
	
	func upd(delta: float, x: float, xd = null):
		if xd == null:
			xd = (x-xp)/delta
			xp = x
		y += delta * yd
		yd += delta * (x+ k3*xd - y - k1*yd)/k2
		return y

