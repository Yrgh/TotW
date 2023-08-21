shader_type spatial;

uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	vec3 noiseLevel = texture(noise,worldPos.xz/noiseScale).rgb;
	ALBEDO = mix(color1,color2,UV.y) * mix(color1,color2,noiseLevel.x);
}
