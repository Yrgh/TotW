extends RigidBody3D
class_name WeaponBody3D
## Used for making weapons in 3D
##
## A class designed for making weapons that can collide with physics objects and report various details when they
## collide with DamagableBody3Ds and EnemyBody3Ds.

enum WeaponStates {
	STASHED,
	READY,
	THROW_READ,
	ATTACKING
}

enum WeaponMaterials {
	UNKNOWN,
	SLATE,
	FLINT,
	SPONGESTONE,
	STONE,
	WOOD,
	TOUGH_WOOD,
	METEOR,
	METAL
}

enum WeaponTypes {
	UNKNOWN,
	SPEAR,
	SHORT_SPEAR,
	HOOKED_SPEAR,
	SHORTWORD,
	GREATSWORD,
	BAT,
	HAMMER,
	WHIP,
	BOW
}

var state := WeaponStates.STASHED

@export_category("Weapon Properties")

@export var weapon_material := WeaponMaterials.UNKNOWN

@export var weapon_type := WeaponTypes.UNKNOWN

var collided_bodies : Array

func check_damage() -> void:
	for body in get_colliding_bodies():
		if body is EnemyBody3D:
			collided_bodies.push_back(get_path_to(body))

func held_process() -> void:
	if state == WeaponStates.ATTACKING:
		check_damage()
	elif state == WeaponStates.READY:
		collided_bodies = []

func _physics_process(_delta: float) -> void:
	if state != WeaponStates.STASHED:
		held_process()



