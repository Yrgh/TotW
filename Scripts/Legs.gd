extends Node3D

@onready var left := $Left
@onready var right := $Right
@onready var lfoot := $CL/Target
@onready var rfoot := $CR/Target
@onready var lfootp := $CL
@onready var rfootp := $CR
@onready var character := $'../Player'

func pythag3d(v: Vector3) -> float:
	return sqrt(v.dot(v))

func pythag2d(v: Vector2) -> float:
	return sqrt(v.dot(v))

func xz(v:Vector3) -> Vector2:
	return Vector2(v.x,v.z)

func unxz(v: Vector2) -> Vector3:
	return Vector3(v.x,0,v.y)

func _physics_process(_delta: float) -> void:
	if pythag2d(xz(lfoot.position)-xz(left.position))>1:
		print("left foot up")
		left.position = lfoot.position
	
	print(pythag2d(xz(lfoot.transform.origin-left.position)))
	print(lfoot.position)
	print(lfoot.transform.origin)
	print(left.position)
	print(left.transform.origin)
	print(lfootp.position)
	print(lfootp.transform.origin)
	
	if pythag2d(xz(rfoot.position)-xz(right.position))>1:
		print("right foot slide")
		right.position = rfoot.position
	
	print("----")
	
	lfootp.position = character.position + unxz(xz(character.velocity)) * .5
	rfootp.position = character.position + unxz(xz(character.velocity)) * .5
	lfootp.rotation = character.rotation
	rfootp.rotation = character.rotation
