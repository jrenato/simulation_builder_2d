class_name BlueprintEntity extends Node2D

## Whether the player can place this object in the world. For example, a lumber axe.
## should not be 'placed' like a machine.
@export var placeable: bool = true

@export var type: Library.TYPE

## We use `find_node()` to search for a `PowerDirection` instance. If it does not exist,
## then we don't worry about it: `find_node()` returns `null` if it finds nothing.
## A faster method would be `get_node()`, which only tests one path.
@onready var power_direction: Node2D = find_child("PowerDirection")


## Rotate the blueprint's direction, if it has one and it is relevant.
func rotate_blueprint() -> void:
	if not power_direction:
		return

	# Get the current directions flags.
	var directions: int = power_direction.output_directions
	# Initialize the new direction value at 0.
	var new_directions := 0

	# Below, we check for each `Types.Direction` against the `directions` value.
	# If a direction is included in the `directions` flag, we "rotate" it using the
	# bitwise pipe operator `|`.
	# LEFT becomes UP
	if directions & Types.Direction.LEFT != 0:
		new_directions |= Types.Direction.UP

	# UP becomes RIGHT
	if directions & Types.Direction.UP != 0:
		new_directions |= Types.Direction.RIGHT

	# RIGHT becomes DOWN
	if directions & Types.Direction.RIGHT != 0:
		new_directions |= Types.Direction.DOWN

	# DOWN becomes LEFT
	if directions & Types.Direction.DOWN != 0:
		new_directions |= Types.Direction.LEFT

	# Set the new direction, which should set the arrow sprites
	power_direction.output_directions = new_directions
