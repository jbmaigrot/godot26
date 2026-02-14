shader_type canvas_item;

uniform float shadow_height : hint_range(0.0, 2.0) = 0.5;
uniform float shadow_skew : hint_range(-2.0, 2.0) = 0.4;
uniform float offset_x : hint_range(-1.0, 1.0) = 0.0;
uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.2, 0.5);

void fragment() {
    // 1. Calcul de l'ombre
    vec2 shadow_uv = UV;
    
    // Application des offsets et du skew
    float x_correction = (UV.y - 1.0) * shadow_skew;
    
    shadow_uv.x += x_correction + offset_x;
    shadow_uv.y = (UV.y + offset_y) / shadow_height;

    // 2. Récupération de la silhouette à partir de la texture originale
    vec4 shadow_tex = texture(TEXTURE, shadow_uv);
    
    // 3. Vérification des bordures et application de la couleur
    if (shadow_uv.y > 1.0 || shadow_uv.y < 0.0 || shadow_uv.x > 1.0 || shadow_uv.x < 0.0) {
        shadow_tex.a = 0.0;
    } else {
        shadow_tex.rgb = shadow_color.rgb;
        shadow_tex.a *= shadow_color.a;
    }

    // 4. Sortie finale : On n'affiche QUE shadow_tex
    COLOR = shadow_tex;
}