shader_type canvas_item;

//A percentage from 0 to 1 for how full the battery is.
uniform float amount : hint_range(0, 1) = 0.0;

void fragment() {
	//We sample the texture as a mask to later change the indicator's color based on its fill rate.
	vec4 mask = texture(TEXTURE, UV);
	//We only need the texture's red channel. The rest, black or transparent, is of
	//no interest.
	float masking_area = mask.r;

	//We Set the percentage of the UV sampling along the X-axis to either 0 or 1,
	//based on how full the battery is. If `amount` is `0.5`, we want the bar to be half full.
	float uv_percentage = step(UV.x, amount);

	//We draw the output pixel using the sprite's `modulate` color and mask out part of it.
	COLOR = vec4(COLOR.rgb, uv_percentage * masking_area);
}
