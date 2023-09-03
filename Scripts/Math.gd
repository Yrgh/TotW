extends Node

func pythag3d(v: Vector3) -> float:
	return sqrt(v.dot(v))

func pythag2d(v: Vector2) -> float:
	return sqrt(v.dot(v))

func xz(v:Vector3) -> Vector2:
	return Vector2(v.x,v.z)

func unxz(v: Vector2) -> Vector3:
	return Vector3(v.x,0,v.y)

func rotate(v: Vector3, r: Vector3) -> Vector3:
	return v.rotated(Vector3.RIGHT,r.x).rotated(Vector3.UP,r.y).rotated(Vector3.FORWARD,r.z)

func get_cross(v: Vector3):
	v = v.normalized()
	
	var dir := Vector3(0,1,0)
	if v.y > .8:
		dir = Vector3(1,0,0)
	
	return v.cross(dir)
