extends Node3D

@onready var legl := $LegLeft
@onready var legr := $LegRight
@onready var targl := $TargetLeft
@onready var targr := $TargetRight
@onready var charac := $'..'

func handle_targets() -> void:
	targl.position = charac.position + M.unxz(M.xz(charac.velocity)) * .125 + (Vector3(-.25,0,0) * charac.transform.basis.inverse())
	targr.position = charac.position + M.unxz(M.xz(charac.velocity)) * .125 + (Vector3(.25,0,0) * charac.transform.basis.inverse())


var rightFoot := false
func _physics_process(_delta:float) -> void:
	handle_targets()
	
	legl.rotation = charac.rotation
	legr.rotation = charac.rotation
	legl.position.y = charac.position.y
	legr.position.y = charac.position.y
	
	if charac.is_on_floor():
		if !rightFoot:
			var r = M.pythag2d(M.xz(legl.transform.origin-targl.position))
			if r>1:
				legl.position = targl.position
			elif r>.5:
				rightFoot = true
		if rightFoot:
			var r = M.pythag2d(M.xz(legr.transform.origin-targr.position))
			if r>1:
				legr.position = targr.position
			elif r>.5:
				rightFoot = false
	else:
		legl.position = targl.position - M.unxz(M.xz(charac.velocity)) * .125
		legr.position = targr.position - M.unxz(M.xz(charac.velocity)) * .125
