class_name Types extends RefCounted

## We store constants for possible directions: up, down, left, and right.
## We'll use bitwise operators to combine them, allowing us to map directions
## to different wire sprites.
## For example, if we combine RIGHT and DOWN below, we will get the number `3`.
## We write these numbers in base 10. If you prefer, you can write them in binary using the
## prefix 0b. For example, 0b0001 is the number `1` in binary, and 0b1000 is the number `8`.
enum Direction { RIGHT = 1, DOWN = 2, LEFT = 4, UP = 8 }

## This dictionary maps our `Direction` values to `Vector2` coordinates, to loop over neighbors of
## a given cell.
const NEIGHBORS: Dictionary = {
	Direction.RIGHT: Vector2i.RIGHT,
	Direction.DOWN: Vector2i.DOWN,
	Direction.LEFT: Vector2i.LEFT,
	Direction.UP: Vector2i.UP
}

# Group name constants. Storing them as constants help prevent typos.
const POWER_MOVERS: String = "power_movers"
const POWER_RECEIVERS: String = "power_receivers"
const POWER_SOURCES: String = "power_sources"
const GUI_ENTITIES: String = "gui_entities"
