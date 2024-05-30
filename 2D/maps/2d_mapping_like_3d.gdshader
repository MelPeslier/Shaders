shader_type canvas_item;

uniform sampler2D texture_albedo : hint_default_black;
uniform float roughness : hint_range(0, 1);
uniform sampler2D texture_metallic : hint_default_black;
uniform sampler2D texture_roughness : hint_roughness_r;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16, 16);
uniform sampler2D texture_ambient_occlusion : hint_default_white;
uniform sampler2D texture_heightmap : hint_default_black;
uniform float heightmap_scale : hint_range(0.0, 1.0) = 0.05;
uniform vec2 heightmap_flip = vec2(1.0, 1.0);
uniform vec2 uv1_scale = vec2(1.0, 1.0);
uniform vec2 uv1_offset = vec2(0.0, 0.0);

void vertex() {
    // Appliquer la height map à la position des sommets
    float height = texture(texture_heightmap, UV).r;
    VERTEX += normalize(VERTEX) * height * heightmap_scale;

    // Mettre à jour les coordonnées UV
    UV = UV * uv1_scale + uv1_offset;
}

void fragment() {
    vec2 base_uv = UV;
    {
        vec3 view_dir = normalize(vec3(-FRAGCOORD.xy, 1.0));
        float depth = 1.0 - texture(texture_heightmap, base_uv).r;
        vec2 ofs = base_uv - view_dir.xy * depth * heightmap_scale * 0.01;
        base_uv = ofs;
    }
    vec4 albedo_tex = texture(TEXTURE, base_uv);
    COLOR.rgb = albedo_tex.rgb;

    float metallic_tex = texture(texture_metallic, base_uv).r;
    float roughness_tex = texture(texture_roughness, base_uv).r;

    // Ici nous ajustons les propriétés métalliques et de rugosité comme requis
    float metallic_value = metallic_tex * metallic;
    float roughness_value = roughness_tex * roughness;

    // Calcul des effets de lumière si nécessaire
    // Notez que les shaders 2D n'ont pas de support direct pour l'éclairage en temps réel comme les shaders 3D.
    // Vous devrez peut-être ajouter vos propres calculs d'éclairage ou utiliser des approches d'éclairage basées sur des textures.

    // Assigner la couleur finale
    COLOR = vec4(COLOR.rgb, albedo_tex.a);
}
