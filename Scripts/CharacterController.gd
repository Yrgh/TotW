extends CharacterBody3D


const BASE_SPEED = 3.0
const SPRINT_SPEED = 4.5
const TIRED_SPEED = 1.5
const JUMP_SPEED_BONUS = 5.0
const JUMP_VELOCITY = 3.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var head := $Neck/Camera3D

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x*.004)
			head.rotate_x(-event.relative.y*.004)
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60),deg_to_rad(90))
	

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized())
	var wasd = false
	if input_dir.x != 0 || input_dir.y != 0:
		Global.walkTime += delta
		wasd = true
	if !wasd || !is_on_floor():
		Global.walkTime = 0
	
	var speed
	if Global.staminaOut:
		speed = TIRED_SPEED
	else:
		speed = BASE_SPEED
	
	if is_on_floor() && Input.is_action_pressed("sprint") && input_dir.y < 0 && Global.stamina > 0 && !Global.staminaOut:
		speed = SPRINT_SPEED
		Global.stamina -= 24 * delta
	
	if is_on_floor():
		velocity.x *= 0.5
		velocity.z *= 0.5
		if wasd:
			Global.stamina += 7 * delta
		else:
			Global.stamina += 21 * delta
	else:
		velocity *= 0.975
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") && is_on_floor() && Global.stamina > 0 && !Global.staminaOut:
		velocity.y = JUMP_VELOCITY
		speed += JUMP_SPEED_BONUS
		Global.stamina -= 7
		
	Global.stamina = clamp(Global.stamina,-1,100)
	
	if is_on_floor():
		if !wasd:
			velocity.x *= .5
			velocity.z *= .5
		if direction:
			velocity.x += direction.x * speed
			velocity.z += direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	
	if transform.origin.y <= -10.0:
		transform.origin = Vector3(0,0,0)
		velocity = Vector3(0,0,0)
	
	head.transform.origin = Vector3(0,.05*sin(4*speed*Global.walkTime),0)

	move_and_slide()
