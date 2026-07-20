shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float resolution = 32.0;
uniform float slices = 5.0;
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.15;

// Função hash robusta para gerar estática pura (sem sin)
float random(vec2 uv) {
    vec3 p3  = fract(vec3(uv.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
    vec2 pixelated_uv = floor(UV * resolution) / resolution;
    float noise = texture(noise_tex, pixelated_uv).r;
    float line_effect = floor(noise * slices) / slices;
    vec4 final_color = mix(light_color, dark_color, line_effect);

    float static_noise = random(FRAGCOORD.xy);
    float color_variation = (static_noise - 0.5) * noise_intensity;
    final_color.rgb += color_variation;

    final_color.a *= COLOR.a;
    COLOR = final_color;
}