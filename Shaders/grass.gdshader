shader_type spatial;
render_mode cull_disabled;

global uniform float WIND_SPEED;
global uniform vec2 WIND_DIR;
global uniform float WIND_POW;

uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noiseC;
uniform float noiseScale = 20.0;
uniform sampler2D noiseD;
uniform sampler2D noiseClouds;
uniform float cloudScale = 40.0;

varying vec3 worldPos;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	
	vec2 displace;
	displace = normalize(WIND_DIR) * texture(noiseD,worldPos.xz/noiseScale+TIME*WIND_SPEED).x * (1.-UV.y) * WIND_POW;
	worldPos.xz += displace;
	VERTEX += (vec4(displace.x, 0.0, displace.y, 1.0) * MODEL_MATRIX).xyz;
}

void fragment() {
	vec3 noiseLevel = texture(noiseC,worldPos.xz/noiseScale).rgb;
	
	float cloud = texture(noiseClouds,worldPos.xz/cloudScale-TIME*WIND_SPEED).x;
	
	ALBEDO = mix(color1,color2,UV.y) * mix(color1,color2,noiseLevel.x) * (.25+.75*cloud);
	
	if(!FRONT_FACING){
		NORMAL = -NORMAL;
	}
}
