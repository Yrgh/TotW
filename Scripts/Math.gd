extends Node

func pythag3d(v: Vector3) -> float:
	return sqrt(v.dot(v))

func pythag2d(v: Vector2) -> float:
	return sqrt(v.dot(v))

func xz(v:Vector3) -> Vector2:
	return Vector2(v.x,v.z)

func unxz(v: Vector2) -> Vector3:
	return Vector3(v.x,0,v.y)
