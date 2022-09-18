shader_type canvas_item;

uniform sampler2D distortionTexture;

void fragment() {
	vec2 distortedUV = SCREEN_UV + texture(distortionTexture, UV).r * 0.025;
	vec4 screenColor = texture(SCREEN_TEXTURE, distortedUV);
	COLOR = screenColor;
}
