extends GPUParticles3D


func _process(delta: float) -> void:
	position = $'../PlayerContainer/Player/Eyes/Camera SpringArm/Camera'.global_position
