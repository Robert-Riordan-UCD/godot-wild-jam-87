shader_type canvas_item;

uniform float intensity = 0.0;

vec2 rand_vec2() {
	return vec2(
		fract(sin(dot(vec2(TIME, TIME), vec2(12.9898,78.233))) * 43758.5453),
		fract(sin(dot(vec2(TIME, TIME+100.0), vec2(12.9898,78.233))) * 43758.5453)
	) * 2.0 - 1.0;
}

void vertex() {
    VERTEX += rand_vec2() * intensity;
}
