shader_type canvas_item;
render_mode blend_mix;

// Paramètres du vent
uniform float speed = 1.0;
uniform float minStrength : hint_range(0.0, 1.0) = 0.05;
uniform float maxStrength : hint_range(0.0, 1.0) = 0.5; // Augmenté pour visibilité
uniform float strengthScale = 10.0; // Réduit pour un contrôle plus fin
uniform float interval = 3.5;
uniform float detail = 1.0;
uniform float distortion : hint_range(0.0, 1.0);
uniform float heightOffset : hint_range(0.0, 1.0) = 0.0;

// Valeur d'offset pour varier le mouvement entre plusieurs objets
uniform float offset = 0.0; 

float getWind(vec2 uv, float time) {
    // Calcul de l'oscillation de la force entre min et max
    float diff = (maxStrength - minStrength) * 0.5;
    float base_strength = minStrength + diff + sin(time / interval) * diff;
    float strength = base_strength * strengthScale;
    
    // Le vent (sinusoïdal) multiplié par la force et le masque de hauteur (UV.y)
    // 1.0 - uv.y signifie que le haut de l'image (y=0) bouge plus que le bas (y=1)
    float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, (1.0 - uv.y) - heightOffset);
    return wind; 
}

void vertex() {
    float time = TIME * speed + offset;
    // On applique le décalage horizontal
    VERTEX.x += getWind(UV, time);
}