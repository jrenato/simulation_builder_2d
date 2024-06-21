extends Entity

# Pre-written the region coordinates for different branches.
# They correspond to the four small branch sprites.
const REGIONS := [
	Rect2(12, 452, 38, 24),
	Rect2(52, 451, 25, 23),
	Rect2(79, 451, 30, 22),
	Rect2(12, 489, 24, 28),
	Rect2(38, 498, 42, 19),
	Rect2(83, 485, 26, 34),
	Rect2(12, 524, 27, 25),
	Rect2(45, 525, 31, 23),
	Rect2(87, 526, 21, 21)
]

@onready var sprite: Sprite2D = %Sprite2D


func _ready() -> void:
	# We set the sprite as one of the four available regions at random.
	# % is the modulus operator and returns the remainder of a division
	# between the two numbers. In this case, it will be between 0 and
	# REGIONS.size() - 1
	sprite.region_rect = REGIONS[randi() % REGIONS.size()]
