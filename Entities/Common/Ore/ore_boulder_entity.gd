extends Entity

## Both regions that represent an ore boulder in the sprite sheet
const REGIONS := [
	Rect2(340, 780, 100, 100),
	Rect2(450, 780, 100, 100),
]

@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_polygon_1: CollisionPolygon2D = %CollisionPolygon2D1
@onready var collision_polygon_2: CollisionPolygon2D = %CollisionPolygon2D2


func _ready() -> void:
	## We set the sprite region to a random region.
	var index: int = randi() % REGIONS.size()
	sprite.region_rect = REGIONS[index]

	## Enable the appropriate collision polygon. Sprite is child 0,
	## so `index` + 1 should be the correct child.
	var collision: CollisionPolygon2D = get_child(index + 1)
	collision.disabled = false
	collision.show()

	## We randomly flip the entire ore boulder on the X axis for more visual variety.
	scale.x = 1 if randf_range(0, 10) < 5 else -1
