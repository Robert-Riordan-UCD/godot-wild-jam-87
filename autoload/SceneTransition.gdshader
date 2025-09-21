shader_type canvas_item;

uniform sampler2D noise;

uniform float left_bound: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float right_bound: hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
	vec4 n = texture(noise, UV);
	
	if (UV.x < left_bound) {
		COLOR.a = mix(1.0, 0.0, 4.0*(left_bound-UV.x));
	} else if (UV.x > right_bound) {
		COLOR.a = mix(1.0, 0.0, 4.0*(UV.x-right_bound));
	}
}