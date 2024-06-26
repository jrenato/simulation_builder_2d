extends Node

@export var simulation_speed: float = 1.0 / 30.0
@export var tile_label_scene: PackedScene

var label_offset: Vector2 = Vector2(-12.5, -12.5)
var _tracker: EntityTracker = EntityTracker.new()

@onready var _ground: TileMapLayer = %GroundTiles
@onready var _barrier: TileMapLayer = %BarrierTiles
@onready var _flat_entities: Node2D = %FlatEntities
@onready var _entity_placer: TileMapLayer = %EntityPlacer
@onready var _player: Player = %Player
@onready var _systems_timer: Timer = %SystemsTimer
@onready var _gui: GameGUI = %GUI

@onready var _power_system: PowerSystem = PowerSystem.new()
@onready var _work_system: WorkSystem = WorkSystem.new()


func _ready() -> void:
	_systems_timer.timeout.connect(_on_systems_timer_timeout)

	_entity_placer.setup(_gui, _tracker, _ground, _flat_entities, _player)
	_systems_timer.start(simulation_speed)
	hide_barrier_layer()

	if _power_system:
		print("Power System enabled")
	if _work_system:
		print("Work System enabled")
	#numerate_ground()


func hide_barrier_layer() -> void:
	#for i in range(_ground.get_layers_count()):
		#if _ground.get_layer_name(i) == 'Barrier':
			#_ground.set_layer_modulate(i, Color(_ground.get_layer_modulate(i), 0.0))
	_barrier.visible = false


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


func _on_systems_timer_timeout() -> void:
	Events.systems_ticked.emit(simulation_speed)
