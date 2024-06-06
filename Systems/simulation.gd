extends Node

@export var simulation_speed: float = 1.0 / 30.0
#@export var tile_label_scene: PackedScene

var label_offset: Vector2 = Vector2(-12.5, -12.5)

var _tracker: EntityTracker = EntityTracker.new()

@onready var _ground: TileMap = %GroundTiles
@onready var _flat_entities: Node2D = %FlatEntities
@onready var _entity_placer: TileMap = %EntityPlacer
@onready var _player: Player = %Player
@onready var _power_system: PowerSystem = PowerSystem.new()


func _ready() -> void:
	for i in range(_ground.get_layers_count()):
		if _ground.get_layer_name(i) == 'Barrier':
			_ground.set_layer_modulate(i, Color(_ground.get_layer_modulate(i), 0.0))

	_entity_placer.setup(_tracker, _ground, _flat_entities, _player)
	#numerate_ground()


#func numerate_ground() -> void:
	#for tile_coord in _ground.get_used_cells(0):
		#add_tile_label(tile_coord)
#
#
#func add_tile_label(tile_coord: Vector2i) -> void:
	#var tile_label: Node2D = tile_label_scene.instantiate()
	#add_child(tile_label)
	#if tile_label:
		#tile_label.label.text = "%s, %s" % [tile_coord.x, tile_coord.y]
		#tile_label.position = _ground.map_to_local(tile_coord) + label_offset


func _on_timer_timeout() -> void:
	Events.systems_ticked.emit(simulation_speed)
