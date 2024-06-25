extends Entity

## Each of the sprite regions with foliage.
const REGIONS := [
	Rect2(10, 560, 210, 210),
	Rect2(230, 560, 210, 210),
	Rect2(450, 560, 210, 210),
	Rect2(670, 560, 210, 210),
]

@onready var foliage_sprite: Sprite2D = %FoliageSprite


func _ready() -> void:
	# Assign random foliage as the region for the sprite.
	foliage_sprite.region_rect = REGIONS[randi() % REGIONS.size()]
	# And flip it horizontally at random for extra variety.
	foliage_sprite.flip_h = randf_range(0, 10) < 5.5
