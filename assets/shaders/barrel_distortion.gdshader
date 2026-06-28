shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

uniform float scanlines_1 = 500.0;
uniform float scanlines_2 = 25.0;
uniform float scan_reduction = 0.1;

uniform float vinnette_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float vinnette_inner_radius = 0.0;
uniform float vinnette_outer_radius = 1.0;

// Цветокоррекция
uniform vec3 color_tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float brightness : hint_range(0.0, 3.0) = 1.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {

    vec2 uv_noise = UV * TIME;
    vec2 uv_scan1 = vec2(UV.x, UV.y + TIME);
    vec2 uv_scan2 = vec2(UV.x, UV.y + TIME * 0.4);

    vec4 screen = texture(screen_tex, UV);

    float scan1 = sin(uv_scan1.y * scanlines_1) * scan_reduction - scan_reduction;
    float scan2 = sin(uv_scan2.y * scanlines_2) * scan_reduction - scan_reduction;

    float noise = random(uv_noise);

    // Виньетка
    float vx = abs(UV.x - 0.5) * 2.0;
    float vy = abs(UV.y - 0.5) * 2.0;
    float v = 1.0 - (1.0 - sqrt(vx * vx + vy * vy) / vinnette_outer_radius)
                    / (1.0 - vinnette_inner_radius);

    screen.rgb -= vec3(v * vinnette_alpha);

    // Шум
    screen.rgb *= noise;

    // Сканлайны
    screen.rgb += scan1;
    screen.rgb += scan2;

    // Цветовой оттенок
    screen.rgb *= color_tint;

    // Насыщенность
    float gray = dot(screen.rgb, vec3(0.299, 0.587, 0.114));
    screen.rgb = mix(vec3(gray), screen.rgb, saturation);

    // Контраст
    screen.rgb = (screen.rgb - 0.5) * contrast + 0.5;

    // Яркость
    screen.rgb *= brightness;

    COLOR = screen;
}