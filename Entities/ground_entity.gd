class_name GroundEntity extends Node2D

## Reference to the blueprint that was just dropped. Grabbed by the inventory
## GUI system when picked up.
var blueprint: BlueprintEntity

## Reference to the nodes that make up this scene so we can animate or
## toggle whether collisions work.
@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer


## Assigns a blueprint, sets graphics, and positions the item
func setup(_blueprint: BlueprintEntity, location: Vector2) -> void:
	blueprint = _blueprint

	# We configure the sprite to be exactly how the blueprint entity's sprite is
	# so it looks the same, just scaled down.
	# Note that for this code to work, every blueprint scene should have a `Sprite`
	# node named "Sprite".
	var blueprint_sprite: Sprite2D = blueprint.get_node("Sprite2D")
	sprite.texture = blueprint_sprite.texture
	sprite.region_enabled = blueprint_sprite.region_enabled
	sprite.region_rect = blueprint_sprite.region_rect
	sprite.centered = blueprint_sprite.centered

	global_position = location

	# Trigger the "pop" animation, where the item goes flying out of where the
	# entity was deconstructed.
	_pop()


## Animates the item so it flies to the player's position before being erased.
func do_pickup(target: CharacterBody2D) -> void:
	# We start with a speed of 10% of the distance. The item starts slow.
	var travel_distance: float = 0.1

	# Prevent the collision of the shape from working. Otherwise, we might pick up
	# the same item twice in a row!
	collision_shape.set_deferred("disabled", true)

	# We'll manually break out of the loop when it's time, so keep looping.
	while true:
		# Calculate the distance to the player.
		var distance_to_target: float = global_position.distance_to(target.global_position)
		# Break out of the loop once we're inside of 5 pixels, which is sufficiently "on top."
		if distance_to_target < 5.0:
			break

		# Interpolate the current position of the ground item by a percentage
		# of the way to the target's position.
		global_position = global_position.move_toward(target.global_position, travel_distance)
		# In our case, starting at 10% and increasing by another 10 every frame,
		# Ramping slow to fast.
		travel_distance += 0.1

		# Await out of the function call until the next frame where we can keep animating.
		await get_tree().process_frame

	# Erase the ground item now that it's reached the player.
	queue_free()


## Animates the item flying out of its starting position in an arc up and down,
## like popcorn.
func _pop() -> void:
	# PI in radians is half a circle, or 180 degrees. So this takes the up direction
	# and rotates it a random amount left and right.
	var direction: Vector2 = Vector2.UP.rotated(randf_range(-PI, PI))

	# In our isometric perspective, every vertical pixel is half a horizontal pixel.
	direction.y /= 2.0
	# Pick a random distance between 20 and 70 pixels.
	direction *= randf_range(20, 70)

	# Pre-calculate the final position
	var target_position := global_position + direction

	# Pre-calculate a point halfway horizontally between start and end point,
	# but twice as high. `sign()` returns -1 if the value is negative and 1 if
	# positive, so we can use it to keep the vertical direction upwards.
	var height_position := global_position + direction * Vector2(0.5, 2 * -sign(direction.y))

	var tween: Tween = create_tween()

	# Interpolate from the start to the middle point
	tween.tween_property(self, "global_position", height_position, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	# Then middle point to end point.
	tween.tween_property(self, "global_position", target_position, 0.25)\
		.set_ease(Tween.EASE_IN)

	await tween.finished
	animation_player.play("hover")
