extends Node

var _tracker: EntityTracker = EntityTracker.new()

@onready var _ground: TileMap = %GroundTiles
@onready var _entity_placer: TileMap = %EntityPlacer
@onready var _player: Player = %Player


func _ready() -> void:
	for i in range(_ground.get_layers_count()):
		if _ground.get_layer_name(i) == 'Barrier':
			_ground.set_layer_modulate(i, Color(_ground.get_layer_modulate(i), 0.0))

	_entity_placer.setup(_tracker, _ground, _player)
