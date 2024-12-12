shader_type canvas_item;

uniform vec2 resolution = vec2(1280, 800);
uniform vec3 spiralColor: source_color = vec3(0.2, 0.6, 0.3);
uniform float alpha: hint_range(0.01, 1.0, 0.01) = 1;
uniform float frequency: hint_range(1.0, 10.0, 0.1) = 8;
uniform float speed: hint_range(-5, 5, 0.1) = 3;
uniform float brightness: hint_range(1, 5, 0.1) = 1;
uniform float balance: hint_range(0, 1, 0.01) = 0.5;
uniform float octaves: hint_range(1, 10, 1) = 4;

float draw_spiral(vec2 uv, float rotation){
	float uvRadius = length(uv);
	float uvPhi = atan(uv.y, uv.x) + rotation;
	float spiralPhi = (log(uvRadius) * frequency - uvPhi) / TAU;
	float spiralCeilRadius = exp((TAU * ceil(spiralPhi) + uvPhi) / frequency);
	float spiralFloorRadius = exp((TAU * floor(spiralPhi) + uvPhi) / frequency);
	return max(abs(uvRadius - spiralCeilRadius), abs(uvRadius - spiralFloorRadius));
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	float spiral = 0.0;
	for(float i = 0.0; i < octaves; i++){
		spiral += draw_spiral(uv, TIME * speed * (0.5 + sin(i)));
	}
	spiral /= octaves;
	vec3 color = spiral * spiralColor;
	COLOR = vec4(color * brightness, 1.0);
	COLOR.a = alpha;
}