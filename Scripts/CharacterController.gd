extends CharacterBody3D

#Constants
const BASE_SPEED = 1.5
const SPRINT_SPEED = 2.5
#When drowsy OR out of stamina
const TIRED_SPEED = 0.75

const JUMP_SPEED_BONUS = 3.0
const JUMP_VELOCITY = 1.5

#Although the character is already above-average,
#we multiply their attributes to make the player
#feel more powerful and not slow
const POWER_MULTIPLIER = 3.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head := $'Eyes/Camera SpringArm'
@onready var body := $Guy
@onready var eyes := $Eyes
@onready var container := $'..'

func diamond(v: Vector2):
	if v.x != 0 && v.y != 0:
		return .5*v
	else:
		return v

func fix_alignment() -> void:
	var id = diamond(Input.get_vector("left", "right", "forward", "backward"))
	var wasd = id.x != 0 || id.y != 0
	if head.spring_length <= .6 || (wasd&&is_on_floor()):
		rotate_y(eyes.rotation.y)
		eyes.rotation.y = 0

func clamp_cam() -> void:
	if head.spring_length <= .11:
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60),deg_to_rad(90))
	else:
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-75),deg_to_rad(10))
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			eyes.rotate_y(-event.relative.x*.004)
			head.rotate_x(-event.relative.y*.004)
			clamp_cam()
			fix_alignment()

func f_to_v3(f: float) -> Vector3:
	return Vector3(f,f,f)

func get_horiz_speed(v: Vector3) -> float:
	return Vector2(v.x,v.z).length()

const walkMult = PI*POWER_MULTIPLIER
func _physics_process(delta: float) -> void:
	clamp_cam()
	fix_alignment()
	
	head.spring_length = Global.animCD.upd(delta,Global.cameraDist)
	
	if Input.is_action_just_pressed('zoom_in'):
		Global.cameraDist -= .5 + Global.cameraDist * .1
	if Input.is_action_just_pressed('zoom_out'):
		Global.cameraDist += .5 + Global.cameraDist * .1
	
	Global.cameraDist = clamp(Global.cameraDist,.1,7.5)
	
	if head.spring_length <= .6:
		body.visible = false
	else:
		body.visible = true
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var wasd = input_dir.x != 0 || input_dir.y != 0
	
	var speed
	if Global.staminaOut:
		speed = TIRED_SPEED
	else:
		speed = BASE_SPEED
	
	if is_on_floor() && Input.is_action_pressed("sprint") && input_dir.y < 0 && Global.stamina > 0 && !Global.staminaOut:
		speed = SPRINT_SPEED
		Global.stamina -= 24 * delta
	
	var wallClimb := is_on_wall() && Input.is_action_pressed("jump") && !Global.staminaOut
	
	if is_on_floor():
		velocity.x *= 0.5
		velocity.z *= 0.5
		if wasd:
			Global.stamina += 7 * delta
		else:
			Global.stamina += 21 * delta
	elif !(wallClimb || Global.climbLastFrame):
		velocity.y -= gravity * delta
	else:
		velocity = f_to_v3(0)
		Global.stamina -= 4 * delta
		if Input.is_action_pressed("forward"):
			velocity.y = 1
			Global.stamina -= 10 * delta
		elif Input.is_action_pressed("backward"):
			velocity.y = -1.1
			Global.stamina -= 7 * delta
	
	if Input.is_action_just_pressed("jump") && is_on_floor() && Global.stamina > 0 && !Global.staminaOut:
		velocity.y = JUMP_VELOCITY  * POWER_MULTIPLIER
		speed += JUMP_SPEED_BONUS
		Global.stamina -= 7 
		
	Global.stamina = clamp(Global.stamina,-1,100)
	
	#Actual movement V
	if is_on_floor() || (Global.climbLastFrame && !wallClimb):
		if !wasd:
			velocity.x *= .5
			velocity.z *= .5
		if direction:
			velocity.x += direction.x * speed * POWER_MULTIPLIER * .5
			velocity.z += direction.z * speed * POWER_MULTIPLIER * .5
			#.5 is for balancing
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	elif !wallClimb:
		velocity *= f_to_v3(.99)
	
	if transform.origin.y <= -10.0:
		transform.origin = f_to_v3(0)
		velocity = f_to_v3(0)
		Global.reset()
	
	Global.climbLastFrame = Input.is_action_pressed("jump") && !Global.staminaOut && !is_on_floor() && (wallClimb || Global.climbLastFrame)
	
	if wasd && is_on_floor():
		Global.walkTime += delta
	else:
		Global.walkTime = 0
	
	if head.spring_length <= .6:
		var inp = Global.walkTime*walkMult*speed
		eyes.position.y = .05*sin(inp) + .02*cos(inp*.5)
		eyes.rotation.z = .01*sin(inp*.5)
		eyes.position.x = .02*cos(inp*.5)
	
	move_and_slide()
