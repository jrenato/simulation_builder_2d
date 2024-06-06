extends TileMap

## Distance from the player when the mouse stops being able to interact.
const MAXIMUM_WORK_DISTANCE: float = 275.0

## When using `world_to_map()` or `map_to_world()`, `TileMap` reports values from the
## top-left corner of the tile. In isometric perspective, it's the top corner
## from the middle. Since we want our entities to be in the middle of the tile,
## we must add an offset to any world position that comes from the map that is
## half the vertical height of our tiles, 25 pixels on the Y-axis here.
const POSITION_OFFSET: Vector2 = Vector2(0, 25)

## Base time in seconds it takes to deconstruct an item.
const DECONSTRUCT_TIME: float = 0.3

## Temporary variable to hold the active blueprint.
## For testing purposes, we hold it here until we build the inventory.
var _blueprint: BlueprintEntity

## The simulation's entity tracker. We use its functions to know if a cell is available or it
## already has an entity.
var _tracker: EntityTracker

## Basically for wires
var _flat_entities: Node2D

## The ground tiles. We can check the position we're trying to put an entity down on
## to see if the mouse is over the tilemap.
var _ground: TileMap

## The player entity. We can use it to check the distance from the mouse to prevent
## the player from interacting with entities that are too far away.
var _player: Player

## The variable below keeps track of the current deconstruction target cell. If the mouse moves
## to another cell, we can abort the operation by checking against this value.
var _current_deconstruct_location: Vector2i = Vector2i.ZERO

## Temporary variable to store references to entities and blueprint scenes.
## We split it in two: blueprints keyed by their names and entities keyed by their blueprints.
## See the `_ready()` function below for an example of how we map a blueprint to a scene.
## Replace the `preload()` resource paths below with the paths where you saved your scenes.
@onready var Library: Dictionary = {
	"StirlingEngine": preload("res://Entities/Entities/StirlingEngine/stirling_engine_blueprint.tscn").instantiate(),
	"Wire": preload("res://Entities/Entities/Wire/wire_blueprint.tscn").instantiate()
}
@onready var _deconstruct_timer: Timer = %DesconstructTimer


func _ready() -> void:
	# Use the existing blueprint to act as a key for the entity scene, so we can instance
	# entities given their blueprint.
	Library[Library.StirlingEngine] = preload("res://Entities/Entities/StirlingEngine/stirling_engine_entity.tscn")
	Library[Library.Wire] = preload("res://Entities/Entities/Wire/wire_entity.tscn")


## Since we are temporarily instancing blueprints for the library until we have
## an inventory system, we must clean up the blueprints when the object leaves the tree.
func _exit_tree() -> void:
	Library.StirlingEngine.queue_free()
	Library.Wire.queue_free()


func _process(delta: float) -> void:
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable
	# If we have a blueprint in hand, keep it updated and snapped to the grid
	if has_placeable_blueprint:
		_move_blueprint_in_world(local_to_map(get_global_mouse_position()))


## Here's our setup() function. It sets the placer up with the data that it needs to function,
## and adds any pre-placed entities to the tracker.
func setup(tracker: EntityTracker, ground: TileMap, flat_entities: Node2D, player: CharacterBody2D) -> void:
	# We use the function to initialize our private references. As mentioned before, this approach
	# makes refactoring easier, as the EntityPlacer doesn't need hard-coded paths to the EntityTracker,
	# GroundTiles, and Player nodes.
	_tracker = tracker
	_flat_entities = flat_entities
	_ground = ground
	_player = player

	# For each child of EntityPlacer, if it extends Entity, add it to the tracker
	# and ensure its position snaps to the isometric grid.
	for child in get_children():
		if child is Entity:
			# Get the world position of the child into map coordinates. These are
			# integer coordinates, which makes them ideal for repeatable
			# Dictionary keys, instead of the more rounding-error prone
			# decimal numbers of world coordinates.
			var map_position: Vector2i = local_to_map(child.global_position)

			# Report the entity to the tracker to add it to the dictionary.
			_tracker.place_entity(child, map_position)


# Below, we start by storing the result of calculations and comparisons in variables. Doing so makes
# the code easy to read.
func _unhandled_input(event: InputEvent) -> void:
	# If the user releases right-click or clicks another mouse button, we can abort.
	# We catch all mouse button inputs here because the `_abort_deconstruct()` function
	# below will safely disconnect the timer and stop it.
	if event is InputEventMouseButton:
		_abort_deconstruct()

	# Get the mouse position in world coordinates relative to world entities.
	# event.global_position and event.position return mouse positions relative
	# to the screen, but we have a camera that can move around the world.
	# That's why we call `get_global_mouse_position()`
	var global_mouse_position: Vector2 = get_global_mouse_position()

	# We check whether we have a blueprint in hand and that the player can place it in the world.
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable

	# We check if the mouse is close enough to the Player node.
	var is_close_to_player: bool = (
		global_mouse_position.distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	# Here, we calculate the coordinates of the cell the mouse is hovering.
	var cellv: Vector2i = local_to_map(global_mouse_position)

	# We check whether an entity exists at that map coordinate or not, to not
	# add entities in occupied cells.
	var cell_is_occupied: bool = _tracker.is_cell_occupied(cellv)

	# We check whether there is a ground tile underneath the current map coordinates.
	# We don't want to place entities out in the air.
	var is_on_ground: bool = _ground.get_cell_source_id(0, cellv) == 0

	# When left-clicking, we use all our boolean variables to check the player can place an entity.
	# Using variables with clear names helps to write code that reads *almost* like English.
	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				_place_entity(cellv)
				_update_neighboring_flat_entities(cellv)
	# When right clicking...
	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		# ...onto a tile within range that has an entity in it,
		if cell_is_occupied and is_close_to_player:
			# we remove that entity.
			_deconstruct(global_mouse_position, cellv)
	# If the mouse moved and we have a blueprint in hand, we update the blueprint's ghost so it
	# follows the mouse cursor.
	elif event is InputEventMouseMotion:
		# If the mouse moves and slips off the target tile, then we can abort
		# the deconstruction process.
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()

		if has_placeable_blueprint:
			_move_blueprint_in_world(cellv)
	# When the user presses the drop button and we are holding a blueprint, we would
	# drop the entity as a dropable entity that the player can pick up.
	# For testing purposes, the following code clears the blueprint from the active slot instead.
	elif event.is_action_pressed("drop") and _blueprint:
		remove_child(_blueprint)
		_blueprint = null
	# We put our quickbar actions for testing purposes and hardcode them to specific entities.
	elif event.is_action_pressed("quickbar_1"):
		if _blueprint:
			remove_child(_blueprint)
		_blueprint = Library.StirlingEngine
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)
	elif event.is_action_pressed("quickbar_2"):
		if _blueprint:
			remove_child(_blueprint)
		_blueprint = Library.Wire
		
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)


## Moves the active blueprint in the world according to mouse movement,
## and tints the blueprint based on whether the tile is valid.
func _move_blueprint_in_world(cellv: Vector2i) -> void:
	# Snap the blueprint's position to the mouse with an offset
	_blueprint.global_position = map_to_local(cellv)# + POSITION_OFFSET

	# Determine each of the placeable conditions
	var is_close_to_player: bool = (
		get_global_mouse_position().distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	var is_on_ground: bool = _ground.get_cell_source_id(0, cellv) == 0
	var cell_is_occupied: bool = _tracker.is_cell_occupied(cellv)

	# Tint according to whether the current tile is valid or not.
	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_blueprint.modulate = Color.WHITE
	else:
		_blueprint.modulate = Color.RED

	if _blueprint is WireBlueprint:
		WireBlueprint.set_sprite_for_direction(_blueprint.sprite, _get_powered_neighbors(cellv))


## Places the entity corresponding to the active `_blueprint` in the world at the specified
## location, and informs the `EntityTracker`.
func _place_entity(cellv: Vector2i) -> void:
	# Use the blueprint we prepared in _ready to instance a new entity.
	var new_entity: Entity = Library[_blueprint].instantiate()

	# Add it to the tilemap as a child so it gets sorted properly
	if _blueprint is WireBlueprint:
		var directions: int = _get_powered_neighbors(cellv)
		_flat_entities.add_child(new_entity)
		WireBlueprint.set_sprite_for_direction(new_entity.sprite, directions)
	else:
		add_child(new_entity)

	# Snap its position to the map, adding `POSITION_OFFSET` to get the center of the grid cell.
	new_entity.global_position = map_to_local(cellv)# + POSITION_OFFSET

	# Call `setup()` on the entity so it can use any data the blueprint holds to configure itself.
	new_entity._setup(_blueprint)

	# Register the new entity in the `EntityTracker` so all the signals can go up, as with systems.
	_tracker.place_entity(new_entity, cellv)


## Returns a bit-wise integer based on whether the nearby objects can carry power.
func _get_powered_neighbors(cellv: Vector2i) -> int:
	# Begin with a blank direction of 0
	var direction: int = 0

	# We loop over each neighboring direction from our `Types.NEIGHBORS` dictionary.
	for neighbor in Types.NEIGHBORS.keys():
		# We calculate the neighbor cell's coordinates.
		var key: Vector2i = cellv + Types.NEIGHBORS[neighbor]

		# We get the entity in that cell if there is one.
		if _tracker.is_cell_occupied(key):
			var entity: Entity = _tracker.get_entity_at(key)

			# If the entity is part of any of the power groups,
			if (
				entity.is_in_group(Types.POWER_MOVERS)
				or entity.is_in_group(Types.POWER_RECEIVERS)
				or entity.is_in_group(Types.POWER_SOURCES)
			):
			# We combine the number with the OR bitwise operator.
			# It's like using +=, but | prevents the same number from adding to itself.
			# Types.Direction.RIGHT (1) + Types.Direction.RIGHT (1) results in DOWN (2), which is wrong.
			# Types.Direction.RIGHT (1) | Types.Direction.RIGHT (1) still results in RIGHT (1).
			# Since we are iterating over all four directions and will not repeat, you can use +,
			# but I use the | operator to be more explicit about comparing bitwise enum FLAGS.
				direction |= neighbor

	return direction


## Looks at each of the neighboring tiles and updates each of them to use the
## correct graphics based on their own neighbors.
func _update_neighboring_flat_entities(cellv: Vector2i) -> void:
	# For each neighboring tile,
	for neighbor in Types.NEIGHBORS.keys():
		# We get the entity, if there is one
		var key: Vector2i = cellv + Types.NEIGHBORS[neighbor]
		var entity: Entity = _tracker.get_entity_at(key)

		# If it's a wire, we have that wire update its graphics to connect to the new
		# entity.
		if entity and entity is WireEntity:
			var tile_directions: int = _get_powered_neighbors(key)
			WireBlueprint.set_sprite_for_direction(entity.sprite, tile_directions)


## Begin the deconstruction process at the current cell
func _deconstruct(event_position: Vector2, cellv: Vector2i) -> void:
	# We connect to the timer's `timeout` signal. We pass in the targeted tile as a
	# bind argument and make sure that the signal disconnects after emitting once
	# using the CONNECT_ONESHOT flag. This is because once the signal has triggered,
	# we do not want to have to disconnect manually. Once the timer ends, the deconstruct
	# operation ends.
		
	# We call the `_finish_deconstruct()` function when the timer times out. We'll code it next.
	_deconstruct_timer.timeout.connect(_finish_deconstruct.bind(cellv), CONNECT_ONE_SHOT)

	# We then start the timer and store the cell we're targeting, which allows us to cancel
	# the operation if the player's mouse moves to another cell.
	_deconstruct_timer.start(DECONSTRUCT_TIME)
	_current_deconstruct_location = cellv


## Finish the deconstruction and delete the entity from the game world.
func _finish_deconstruct(cellv: Vector2i) -> void:
	# This function will drop the deconstructed entity as a pickup item,
	# but we haven't implemented an inventory yet, so we only remove the entity.
	#var entity: Entity = _tracker.get_entity_at(cellv)
	_tracker.remove_entity(cellv)
	_update_neighboring_flat_entities(cellv)


func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", _finish_deconstruct):
		_deconstruct_timer.disconnect("timeout", _finish_deconstruct)
	_deconstruct_timer.stop()
