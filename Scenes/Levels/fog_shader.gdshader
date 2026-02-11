shader_type canvas_item;

uniform float speed : hint_range(0.0, 3.0) = 2.0;
uniform float movement_amplitude : hint_range(0.0, 10.0) = 1.0;
uniform float alpha_min : hint_range(0.0, 1.0) = 0.9; // Limite la transparence minimum du shader

void fragment() {
    // --- NOUVEAU : On récupère l'alpha du script (self_modulate) ---
    float input_alpha = COLOR.a;
    
    // 1. On récupère la couleur de ta tuile
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 2. Désynchronisation par position
    float variation = (FRAGCOORD.x + FRAGCOORD.y) * 0.01;
    
    // 3. Calcul du mouvement Haut/Bas (appliqué aux UV)
    float bobbing = sin(TIME * speed + variation) * (movement_amplitude * 0.01);
    vec2 moving_uv = vec2(UV.x, UV.y + bobbing);
    
    // 4. Lecture de la texture avec le mouvement
    vec4 final_color = texture(TEXTURE, moving_uv);
    
    // 5. Calcul de l'Alpha interne (ton effet de pulsation)
    float pulse = mix(alpha_min, 1.0, 0.5 + 0.5 * cos(TIME * speed * 0.7 + variation));
    
    // --- MODIFICATION ICI ---
    // On applique la couleur de la texture
    COLOR.rgb = final_color.rgb;
    // L'alpha final est : (Alpha de la texture) * (Alpha du pulse) * (Alpha du self_modulate)
    COLOR.a = final_color.a * pulse * input_alpha;
}