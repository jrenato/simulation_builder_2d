extends Entity

# Pre-written the region coordinates for different branches.
# They correspond to the four small branch sprites.
const REGIONS := [
	Rect2(135, 450, 24, 42),
	Rect2(177, 450, 41, 42),
	Rect2(125, 505, 39, 45),
	Rect2(180, 498, 38, 52)
]

@onready var sprite: Sprite2D = %Sprite2D


func _ready() -> void:
	# We set the sprite as one of the four available regions at random.
	# % is the modulus operator and returns the remainder of a division
	# between the two numbers. In this case, it will be between 0 and
	# REGIONS.size() - 1
	sprite.region_rect = REGIONS[randi() % REGIONS.size()]
