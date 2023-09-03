extends CollisionShape3D

@onready var terrain_map : Image
@onready var amplitude : float
@onready var offset : float

func create_collision_points() -> void:
	var terrain = $'../..'
	
	terrain_map = terrain.mesh.surface_get_material(0).get_shader_parameter('heightmap').get_image()
	amplitude = terrain.mesh.surface_get_material(0).get_shader_parameter('amplitude')
	offset = terrain.mesh.surface_get_material(0).get_shader_parameter('terrain_offset')
	
	terrain_map.resize(50,50)
	
	var new_shape = HeightMapShape3D.new()
	shape = new_shape
	
	var arr : Array
	
	for x in range(0,50):
		for y in range(0,50):
			arr.push_back(terrain_map.get_pixel(x,y).r * amplitude + offset)
	
	shape.map_data = arr
