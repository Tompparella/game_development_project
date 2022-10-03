shader_type canvas_item;

uniform sampler2D gradient;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	float brightness = (pixelColor.r + pixelColor.b + pixelColor.g) / 3.0;
	vec4 gradientColor = texture(gradient, vec2(brightness));
	COLOR = gradientColor;
}