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
const POWER_MULTIPLIER = 3.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head := $'Eyes/Camera SpringArm'
@onready var body := $Guy
@onready var eyes := $Eyes
@onready var container := $'..'
@onready var fpsText := $'../../UI/FPSDisplay'
@onready var graphics = $'../../WorldEnvironment'.environment
@onready var tool := $'../../Spear'
@onready var menu := $'../../UI/Menu'

var toolHeld := true

func killcheck(node:Node3D) -> bool:
	if node.global_position.y < -10.0:
		node.transform.origin = Vector3(0,1,0)
		if node is RigidBody3D:
			node.linear_velocity = f_to_v3(0)
			node.angular_velocity = f_to_v3(0)
		else:
			node.velocity = f_to_v3(0)
		node.rotation = f_to_v3(0)
		return true
	else:
		return false

func fix_tool() -> void:
	if toolHeld:
		tool.position = position + Vector3(0.654,1.423,-1.74) * transform.basis.inverse()
		tool.rotation = rotation + Vector3(deg_to_rad(-18.3),deg_to_rad(180),0)
	
	tool.get_node('CollisionShape3D').disabled = toolHeld
	
	if !menu.visible && Input.is_action_just_pressed("item") && !toolHeld && M.pythag3d(tool.global_position-global_position)<4.0:
		toolHeld = true
	elif !menu.visible && Input.is_action_just_pressed("item") && toolHeld:
		tool.linear_velocity = velocity
		toolHeld = false

func throw_tool() -> void:
	var throw_dir = (Vector3(0,0,-1).normalized() * transform.basis.inverse()).rotated(Vector3(1,0,0),head.rotation.x)
	tool.linear_velocity = velocity + throw_dir * 15 + Vector3(0,10,0)
	tool.angular_velocity = f_to_v3(0)
	tool.rotation = tool.rotation.rotated(tool.linear_velocity.normalized(),f_to_v3(0).angle_to(tool.linear_velocity))
	toolHeld = false

func diamond(v: Vector2):
	if v.x != 0 && v.y != 0:
		return .5*v
	else:
		return v

func fix_alignment() -> void:
	var id = diamond(Input.get_vector("left", "right", "forward", "backward"))
	var wasd = (id.x != 0 || id.y != 0)
	if head.spring_length <= .6 || (wasd&&is_on_floor()):
		rotate_y(eyes.rotation.y)
		eyes.rotation.y = 0

func clamp_cam() -> void:
	if head.spring_length <= .11:
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60),deg_to_rad(90))
	else:
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-75),deg_to_rad(10))
	
var inputs = []

func _unhandled_input(event: InputEvent) -> void:
	inputs.append(event)

func unwanted() -> void:
	for event in inputs:
		if event is InputEventMouseButton:
			if event.button_index == 1:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				menu.visible = false
		
		elif event.is_action_released("inven"):
			if !menu.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				menu.visible = true
			elif !menu.current_tab==2:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				menu.visible = false
		
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				eyes.rotate_y(-event.relative.x*.004)
				head.rotate_x(-event.relative.y*.004)
				clamp_cam()
				fix_alignment()
				fix_tool()
	
	inputs = []

func f_to_v3(f: float) -> Vector3:
	return Vector3(f,f,f)

func get_horiz_speed(v: Vector3) -> float:
	return Vector2(v.x,v.z).length()

const walkMult = PI*POWER_MULTIPLIER
var physicsFPS
func _physics_process(delta: float) -> void:
	clamp_cam()
	fix_alignment()
	
	var fov
	
	physicsFPS = 1/delta
	
	if !menu.visible && Input.is_action_just_pressed('focus(toggle)'):
		if Global.ATSon:
			Global.ATSon = false
		else:
			Global.ATSon = true
	
	if (!menu.visible && Input.is_action_pressed('focus(hold)') || Global.ATSon) && !Global.staminaOut:
		Global.applicableTimeScale = .125
		Global.stamina -= delta * 21
		fov = 60
		graphics.adjustment_contrast = 1.4
		graphics.adjustment_saturation = 0.3
	else:
		Global.applicableTimeScale = 1
		fov = 80
		graphics.adjustment_contrast = 1.1
		graphics.adjustment_saturation = 1.1
	
	delta *= Global.applicableTimeScale
	
	head.spring_length = Global.animCD.upd(delta,Global.cameraDist)
	
	if !menu.visible && Input.is_action_just_pressed('zoom_in'):
		Global.cameraDist -= .5 + Global.cameraDist * .1
	if !menu.visible && Input.is_action_just_pressed('zoom_out'):
		Global.cameraDist += .5 + Global.cameraDist * .1
	
	Global.cameraDist = clamp(Global.cameraDist,.1,7.5)
	
	if head.spring_length <= .6:
		body.transparency = 1
	else:
		body.transparency = 0
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var wasd = (input_dir.x != 0 || input_dir.y != 0)
	
	var speed
	if Global.staminaOut:
		speed = TIRED_SPEED
		fov -= 5
	else:
		speed = BASE_SPEED
	
	if is_on_floor() && !menu.visible && Input.is_action_pressed("sprint") && input_dir.y < 0 && Global.stamina > 0 && !Global.staminaOut:
		speed = SPRINT_SPEED
		Global.stamina -= 24 * delta
		fov += 15
	
	var wallClimb = is_on_wall() && !menu.visible && Input.is_action_pressed("jump") && !Global.staminaOut
	
	if  Input.is_action_pressed('lclick') && Input.is_action_pressed('rclick') && toolHeld:
		rotate_y(eyes.rotation.y)
		eyes.rotation.y = 0
	
	if Input.is_action_just_released('lclick') && Input.is_action_just_released('rclick') && toolHeld:
		throw_tool()
	
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
		if !menu.visible && Input.is_action_pressed("forward"):
			velocity.y = 1
			Global.stamina -= 10 * delta
		elif !menu.visible && Input.is_action_pressed("backward"):
			velocity.y = -1.1
			Global.stamina -= 7 * delta
	
	if !menu.visible && Input.is_action_just_pressed("jump") && is_on_floor() && Global.stamina > 0 && !Global.staminaOut:
		velocity.y = JUMP_VELOCITY  * POWER_MULTIPLIER
		speed += JUMP_SPEED_BONUS
		Global.stamina -= 7
		
	Global.stamina = clamp(Global.stamina,-1,100)
	
	#Actual movement V
	if is_on_floor() || (Global.climbLastFrame && !wallClimb):
		if !wasd:
			velocity.x *= .5
			velocity.z *= .5
		elif direction:
			fov += 5
				
			velocity.x += direction.x * speed * POWER_MULTIPLIER * .5
			velocity.z += direction.z * speed * POWER_MULTIPLIER * .5
			#.5 is for balancing
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	elif !wallClimb:
		velocity *= f_to_v3(.99)
	
	if killcheck(self):
		Global.reset()
	killcheck(tool)
	
	Global.climbLastFrame = !menu.visible && Input.is_action_pressed("jump") && is_on_wall() && !Global.staminaOut && !is_on_floor() && (wallClimb || Global.climbLastFrame)
	
	if wasd && is_on_floor():
		Global.walkTime += delta
	else:
		Global.walkTime = 0
	
	if head.spring_length <= .6:
		var inp = Global.walkTime*walkMult*speed
		eyes.position.y = .05*sin(inp) + .02*cos(inp*.5)
		eyes.rotation.z = .01*sin(inp*.5)
		eyes.position.x = .02*cos(inp*.5)
	
	$'Eyes/Camera SpringArm/Camera'.fov = Global.FOV.upd(delta,fov)
	
	fix_tool()
	
	move_and_slide()
		
	unwanted()
	
	Global.player_position = global_position
	#process(delta)

func _process(delta: float) -> void:
	fpsText.visible = Global.perf_shown
	if Global.perf_shown:
		fpsText.text = "FPS: " + str(1/delta)
	$'Eyes/Camera SpringArm/Camera/PostProcess'.visible = Global.vfx_shown
