#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(binding = 0, set = 1) uniform sampler2D font_texture;
layout(push_constant, std430) uniform Params {
	float char_width;
	float char_height;
	float symbol_variety;
} p;

float get_brightness(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	
	int char_w = int(p.char_width);
	int char_h = int(p.char_height);
	
	ivec2 block_start = (pixel / ivec2(char_w, char_h)) * ivec2(char_w, char_h);
	
	vec3 avg_color = vec3(0.0);
	for (int x = 0; x < char_w; x++) {
		for (int y = 0; y < char_h; y++) {
			avg_color += imageLoad(screen_tex, block_start + ivec2(x, y)).rgb;
		}
	}
	avg_color /= float(char_w * char_h);
	
	float brightness = clamp(get_brightness(avg_color), 0.0, 1.0);
	int char_index = int(brightness * 15.0) * int(16.0 / p.symbol_variety);
	
	// Локальная позиция внутри символа
	float local_x = fract(float(pixel.x) / float(char_w));
	float local_y = fract(float(pixel.y) / float(char_h));
	
	// Сетка 16×16
	int chars_per_row = 16;
	int char_row = char_index / chars_per_row;
	int char_col = char_index % chars_per_row;
	
	float symbol_width = 1.0 / 16.0;   // 1/16 ширины
	float symbol_height = 1.0 / 16.0;  // 1/16 высоты
	
	float font_uv_x = float(char_col) * symbol_width + local_x * symbol_width;
	float font_uv_y = float(char_row) * symbol_height + local_y * symbol_height;
	
	vec4 char_color = texture(font_texture, vec2(font_uv_x, font_uv_y));
	
	vec4 color = mix(vec4(avg_color, 1.0), char_color, char_color.a);
	imageStore(screen_tex, pixel, color);
}