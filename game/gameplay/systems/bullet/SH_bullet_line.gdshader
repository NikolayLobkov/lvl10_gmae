shader_type spatial;
render_mode cull_disabled;

uniform vec4 bullet_color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float progress: hint_range(0.0, 1.0, 0.01) = 0.0f;

void fragment() {
	
	ALBEDO = bullet_color.rgb;
	
	ALPHA = bullet_color.a * float(UV.y > progress);
	
	EMISSION = ALBEDO;
}
