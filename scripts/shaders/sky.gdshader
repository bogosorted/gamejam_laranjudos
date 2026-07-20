shader_type canvas_item;

uniform vec4 sky_color : source_color = vec4(0.05, 0.05, 0.1, 1.0);
uniform vec4 bg_star_color : source_color = vec4(0.6, 0.6, 0.8, 1.0);
uniform vec4 fg_star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float bg_density : hint_range(0.0, 1.0) = 0.005;

uniform vec2 cam_pos = vec2(0.0);

float random(vec2 uv) {
    vec3 p3  = fract(vec3(uv.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
    vec2 base_pos = floor(FRAGCOORD.xy);
    float fg_density = 0.0008;
    vec2 pos_bg = base_pos + floor(cam_pos * 0.0001);
    float star_bg = step(1.0 - bg_density, random(pos_bg));
    
    vec2 pos_fg = base_pos + floor(cam_pos * 0.003);
    float star_fg = step(1.0 - fg_density, random(pos_fg + vec2(139.42, 281.33)));
    
    vec4 final_color = mix(sky_color, bg_star_color, star_bg);
    final_color = mix(final_color, fg_star_color, star_fg);
    
    COLOR = final_color;
}