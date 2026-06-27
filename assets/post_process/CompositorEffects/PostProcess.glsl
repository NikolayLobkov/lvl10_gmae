#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(push_constant, std430) uniform Params {
	float brightness;
	float saturation;
	float pixel_size;
	float blur_radius;
} p;

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec4 color = imageLoad(screen_tex, pixel);  // Читаем оригинальный пиксель
	
	// Пикселизация
	if (p.pixel_size > 0.0) {
		ivec2 block_center = (pixel / ivec2(p.pixel_size)) * ivec2(p.pixel_size) + ivec2(p.pixel_size) / 2;
		color = imageLoad(screen_tex, clamp(block_center, ivec2(0), imageSize(screen_tex) - 1));
	}
	
	// Saturation + Brightness
	float gray = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
	color.rgb = mix(vec3(gray), color.rgb, p.saturation) * p.brightness;
	
	// Blur (опционально, только если включен)
	if (p.blur_radius > 0.0) {
		int blur_int = int(p.blur_radius);
		vec4 result = vec4(0.0);
		int count = 0;
		
		for (int x = -blur_int; x <= blur_int; x++) {
			for (int y = -blur_int; y <= blur_int; y++) {
				result += imageLoad(screen_tex, clamp(pixel + ivec2(x, y), ivec2(0), imageSize(screen_tex) - 1));
				count++;
			}
		}
		result /= float(count);
		color = mix(color, result, 0.3);  // Blend вместо полной замены
	}
	
	imageStore(screen_tex, pixel, color);
}