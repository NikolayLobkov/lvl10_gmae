#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(push_constant, std430) uniform Params {
	float dot_size;
	float dot_density;
} p;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float distance_to_nearest_dot(vec2 uv, float seed) {
	vec2 grid_uv = uv * p.dot_density;
	vec2 grid_cell = floor(grid_uv);
	vec2 local_uv = fract(grid_uv);
	
	float min_dist = 2.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 cell = grid_cell + vec2(x, y);
			vec2 dot_pos = fract(random(cell + seed) * 0.5 + vec2(0.5));
			float dist = distance(local_uv, dot_pos + vec2(x, y));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec2 uv = vec2(pixel) / imageSize(screen_tex);
	
	vec4 original = imageLoad(screen_tex, pixel);
	
	// Разложим на CMYK компоненты
	float cyan = 1.0 - original.r;
	float magenta = 1.0 - original.g;
	float yellow = 1.0 - original.b;
	
	// Для каждого канала свой набор точек (сдвинутые)
	float dist_c = distance_to_nearest_dot(uv + vec2(0.0, 0.0), 1.0);
	float dist_m = distance_to_nearest_dot(uv + vec2(0.2, 0.0), 2.0);
	float dist_y = distance_to_nearest_dot(uv + vec2(0.1, 0.17), 3.0);
	
	// Размер точек зависит от компонента цвета
	float dot_c = cyan * p.dot_size;
	float dot_m = magenta * p.dot_size;
	float dot_y = yellow * p.dot_size;
	
	// Определяем какие точки видны
	float c_visible = (dist_c < dot_c) ? 1.0 : 0.0;
	float m_visible = (dist_m < dot_m) ? 1.0 : 0.0;
	float y_visible = (dist_y < dot_y) ? 1.0 : 0.0;
	
	// Комбинируем CMYK обратно в RGB
	vec3 color = vec3(1.0) - vec3(
		c_visible,
		m_visible,
		y_visible
	);
	
	// Смешиваем с оригиналом для мягкости
	vec3 final = mix(original.rgb, color, 0.8);
	
	imageStore(screen_tex, pixel, vec4(final, original.a));
}