extends Node

var _tracker: EntityTracker = EntityTracker.new()

@onready var _ground: TileMap = %GroundTiles
@onready var _entity_placer: TileMap = %EntityPlacer
@onready var _player: Player = %Player


func _ready() -> void:
	_ground.set_layer_modulate(1, Color(_ground.get_layer_modulate(1), 0.0))
	_entity_placer.setup(_tracker, _ground, _player)
