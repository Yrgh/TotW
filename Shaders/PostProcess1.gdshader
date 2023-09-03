shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform sampler2D depth_tex : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D norm_rough : hint_normal_roughness_texture, filter_linear_mipmap;

global uniform float zNear;
global uniform float zFar;

float true_depth(mat4 inv_proj_matrix, vec2 screen_uv, vec4 depth) {
	vec3 ndc = vec3(screen_uv,depth.x) * 2.0 - 1.0;
	vec4 view = inv_proj_matrix * vec4(ndc,1.0);
	view /= view.w;
	return (zFar * zNear) / (zFar + (view.z * (zNear - zFar)));
}

vec4 sample_screen(vec2 uv) {
	return texture(screen_tex,uv);
}

const vec2[9] directions = vec2[9](
	vec2(-1.0,-1.0), vec2(0.0,-1.0), vec2(1.0,-1.0),
	vec2(-1.0,0.0), vec2(0.0,0.0), vec2(1.0,0.0),
	vec2(-1.0,1.0), vec2(0.0,1.0), vec2(1.0,1.0)
);

mat3[4] fetch_pixels(vec2 uv,vec2 displacement,sampler2D tex) {
	vec4[9] samples;
	
	for (int i = 0; i < 9; i++) {
		samples[i] = pow(texture(tex,uv+displacement*directions[i]),vec4(1.0));
	}
	
	mat3[4] output;
	
	for (int i = 0; i < 4; i++) {
		output[i] = mat3(
			vec3(samples[0][i],samples[1][i],samples[2][i]),
			vec3(samples[3][i],samples[4][i],samples[5][i]),
			vec3(samples[6][i],samples[7][i],samples[8][i])
		);
	}
	
	return output;
}

const mat3 sobel_x_kernel = mat3(
	vec3(1.0,0.0,-1.0),
	vec3(2.0,0.0,-2.0),
	vec3(1.0,0.0,-1.0)
);

const mat3 sobel_y_kernel = mat3(
	vec3(1.0,2.0,1.0),
	vec3(0.0,0.0,0.0),
	vec3(-1.0,-2.0,-1.0)
);

vec4 use_kernel(vec2 uv, vec2 displacement,mat3 kernel,sampler2D tex) {
	mat3[4] area = fetch_pixels(uv,displacement,tex);
	vec4 val;
	
	for (int i = 0; i < 4; i++) {
		mat3 ch = area[i];
		mat3 v = matrixCompMult(kernel,ch);
		float f = 
			v[0][0] + v[1][0] + v[2][0] +
			v[0][1] + v[1][1] + v[2][1] +
			v[0][2] + v[1][2] + v[2][2];
		val[i] = f;
	}

	return val;
}

vec4 sobel(vec2 uv,vec2 displacement,sampler2D tex) {
	vec4 x = use_kernel(uv,displacement,sobel_x_kernel,tex);
	vec4 y = use_kernel(uv,displacement,sobel_y_kernel,tex);
	
	return sqrt(x*x+y*y);
}

void fragment() {
	vec4 original = sample_screen(SCREEN_UV);
	
	float depth = true_depth(INV_PROJECTION_MATRIX,SCREEN_UV,texture(depth_tex,SCREEN_UV));
	
	vec4 outline = 1.0 - ((sobel(SCREEN_UV, 1.0 / VIEWPORT_SIZE,depth_tex).x > 0.004) ? vec4(1.0) : vec4(0.0));
	
	original *= outline;
	
	original = 1.0 + (original - 1.0) / (original + 1.0);
	
	ALBEDO = original.xyz;
}
