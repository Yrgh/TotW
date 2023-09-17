extends CharacterBody3D
class_name EnemyBody3D


const SPEED = 4.5
const ACCEL = 9.0

const SPAWN = Vector3(63.204,4,-56.65)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var nav := $NavigationAgent3D

func view_to(v:Vector3) -> float:
	return .5*M.pythag3d(v) + .5*M.pythag2d(M.xz(v))

var searchingTime = 0
func _physics_process(delta: float) -> void:
	
	var dir := Vector3()
	
	var target := Global.player_position
	
	var dist_to := view_to(target-global_position)
	if dist_to>30.0:
		target = SPAWN
	
	if view_to(SPAWN-global_position)>1.0 || dist_to<30.0:
		
		var horiz_dir := M.xz(target-global_position)
		basis = basis.slerp(Basis(Vector3(0,1,0),-atan2(horiz_dir.y,horiz_dir.x)).orthonormalized(),.05)
		
		nav.target_position = target
		
		dir = nav.get_next_path_position() - global_position
		dir = dir.normalized()
		
		velocity = velocity.lerp(dir*SPEED,ACCEL*delta)
		searchingTime = 0
	else:
		searchingTime += delta
		rotation.y = sin(searchingTime) * PI/4

	move_and_slide()
