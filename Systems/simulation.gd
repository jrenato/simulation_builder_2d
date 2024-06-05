extends Node


@onready var _ground: TileMap = %GroundTiles


func _ready() -> void:
	_ground.set_layer_modulate(1, Color(_ground.get_layer_modulate(1), 0.0))
