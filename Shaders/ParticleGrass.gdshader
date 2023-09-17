shader_type particles;
render_mode disable_force,disable_velocity;

group_uniforms Generation;
uniform float rows = 100.0;
global uniform sampler2D terrain_map;
global uniform float terrain_offset = 0.0;
global uniform float terrain_amplitude = 20.0;
uniform float altitude_min : hint_range(-100.0, 500.0, 1.0) = 0.0;
uniform float altitude_max : hint_range(0.0, 1000.0, 1.0) = 1000.0;
uniform float jitter = .5;
uniform bool rotate = true;
uniform float spacing = 1.0;
uniform bool use_normal;
uniform sampler2D terrain_normal : hint_normal;
uniform vec3 scale = vec3(1.0);
uniform vec3 scale_randomness = vec3(0.0);

group_uniforms DynamicInfo;

mat4 rotate_full(mat4 current,vec3 angles) {
	float ca = cos(angles.x);
	float cb = cos(angles.y);
	float cc = cos(angles.z);
	
	float sa = sin(angles.x);
	float sb = sin(angles.y);
	float sc = sin(angles.z);
	
	return current * mat4(
		vec4(ca*cb, sa*sb*cc - ca*sc, ca*sb*cc + sa*sc, 0.0),
		vec4(sa*cb, sa*sb*sc + ca*cc, sa*sb*cc - ca*sc, 0.0),
		vec4(-sb, cb*sc, cb*cc, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
}

// Dave Hoskins on Shadertoy.com
float hash(float p) {
    p = fract(p * .1032);
    p *= p + 19.29;
    p *= p + p;
    return fract(p);
}

vec3 get_position_from_transform(mat4 transform) {
	return vec3(
		transform[3][0],
		transform[3][1],
		transform[3][2]);
}

void process() {
	//vec3 normal = (use_normal)? texture(terrain_normal, target_position.xz).xyz :vec3(1.0,0.0,0.0);
	vec3 position = vec3(0.0);
	float seed = 0.0;
	vec3 emitter_pos = get_position_from_transform(EMISSION_TRANSFORM);
	
	position.z = float(INDEX);
	position.x = mod(position.z,rows);
	position.z = (position.z - position.x) / rows;
	
	position = trunc(position);
	
	vec3 int_pos = position;
	
	position.x -= 0.5 * rows;
	position.z -= 0.5 * rows;
	
	position.x *= spacing;
	position.z *= spacing;
	
	position += emitter_pos - mod(emitter_pos,1.0);
	int_pos += trunc(emitter_pos);
	
	int_pos = trunc(int_pos);
	
	seed = -int_pos.x;
	seed += seed * int_pos.z;
	seed = mod(seed,rows) + int_pos.z;
	
	position.x += (2.0 * jitter - 1.0) * hash(seed*.965);
	position.z += (2.0 * jitter - 1.0) * hash(seed*.877); 
	
	position.y = terrain_amplitude * texture(terrain_map,position.xz / 200.0).x + terrain_offset;
	
	TRANSFORM = mat4(1.0);
	
	TRANSFORM[3][0] = position.x;
	TRANSFORM[3][1] = position.y;
	TRANSFORM[3][2] = position.z;
	
	TRANSFORM[0][0] = scale.x + scale_randomness.x * (2.0 * hash(seed*1.031) - 1.0);
	TRANSFORM[1][1] = scale.y + scale_randomness.y * (2.0 * hash(seed*0.962) - 1.0);
	TRANSFORM[2][2] = scale.z + scale_randomness.z * (2.0 * hash(seed*1.103) - 1.0);
	
	vec3 rotation = (rotate)?vec3(0.0, TAU * hash(seed), 0.0) :vec3(0.0,0.0,0.0);
	
	TRANSFORM = rotate_full(TRANSFORM,rotation);
}
