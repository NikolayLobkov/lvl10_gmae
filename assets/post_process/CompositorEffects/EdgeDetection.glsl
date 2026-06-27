#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(binding = 0, set = 1) uniform sampler2D normal_roughness_tex;
layout(push_constant, std430) uniform Params {
	float edge_threshold_min;
	float edge_threshold_max;
	float edge_width;
	float edge_strength;
	vec4 edge_color;
	vec4 background_color;
} p;

vec4 normal_roughness_compatibility(vec4 p_normal_roughness) {
	float roughness = p_normal_roughness.w;
	if (roughness > 0.5) {
		roughness = 1.0 - roughness;
	}
	roughness /= (127.0 / 255.0);
	return vec4(normalize(p_normal_roughness.xyz * 2.0 - 1.0) * 0.5 + 0.5, roughness);
}

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec2 uv = vec2(pixel) / imageSize(screen_tex);
	vec2 offset = vec2(p.edge_width) / imageSize(screen_tex);
	
	vec4 original_color = imageLoad(screen_tex, pixel);
	
	vec4 center = texture(normal_roughness_tex, uv);
	center = normal_roughness_compatibility(center);
	
	vec4 n = texture(normal_roughness_tex, uv + vec2(0.0, -offset.y));
	n = normal_roughness_compatibility(n);
	
	vec4 s = texture(normal_roughness_tex, uv + vec2(0.0, offset.y));
	s = normal_roughness_compatibility(s);
	
	vec4 e = texture(normal_roughness_tex, uv + vec2(offset.x, 0.0));
	e = normal_roughness_compatibility(e);
	
	vec4 w = texture(normal_roughness_tex, uv + vec2(-offset.x, 0.0));
	w = normal_roughness_compatibility(w);
	
	float edge = length(n.xyz - center.xyz) + length(s.xyz - center.xyz) + 
	             length(e.xyz - center.xyz) + length(w.xyz - center.xyz);
	
	edge *= p.edge_strength;
	edge = smoothstep(p.edge_threshold_min, p.edge_threshold_max, edge);
	
	// Смешиваем с оригинальным цветом
	vec4 edge_color_mixed = mix(p.background_color, p.edge_color, edge);
	vec4 final_color = mix(original_color, edge_color_mixed, edge_color_mixed.a);
	
	imageStore(screen_tex, pixel, final_color);
}