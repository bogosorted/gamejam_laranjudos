shader_type canvas_item;

uniform vec4 inner_color : source_color = vec4(0.6, 0.9, 1.0, 0.8);
uniform vec4 middle_color : source_color = vec4(0.2, 0.6, 1.0, 0.4);
uniform vec4 outer_color : source_color = vec4(0.0, 0.2, 0.8, 0.0);

uniform float inner_radius : hint_range(0.0, 0.5) = 0.2;
uniform float middle_radius : hint_range(0.0, 0.5) = 0.35;
uniform float outer_radius : hint_range(0.0, 0.5) = 0.5;

void fragment() {
    float dist = distance(UV, vec2(0.5));
    
    float t1 = smoothstep(inner_radius, middle_radius, dist);
    float t2 = smoothstep(middle_radius, outer_radius, dist);
    
    vec4 color_mix = mix(inner_color, middle_color, t1);
    vec4 final_color = mix(color_mix, outer_color, t2);
    
    COLOR = final_color;
}