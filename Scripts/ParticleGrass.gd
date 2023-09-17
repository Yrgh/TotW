extends GPUParticles3D

@onready var cam = $'../PlayerContainer/Player/Eyes/Camera SpringArm/Camera'

func _process(delta: float) -> void:
	var dist_from_desired = .5 * process_material.get_shader_parameter('rows') * process_material.get_shader_parameter('spacing')
	position = cam.global_position + (cam.global_transform.basis * Vector3(0,0,-dist_from_desired))
