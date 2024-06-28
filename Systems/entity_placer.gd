extends TileMapLayer

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

## The ground item packed scene we instance when dropping items
var GroundItemScene: PackedScene = preload("res://Entities/ground_entity.tscn")

## Reference for gui to access the mouse's inventory
var _gui: GameGUI

## The simulation's entity tracker. We use its functions to know if a cell is available or it
## already has an entity.
var _tracker: EntityTracker

## Basically for wires
var _flat_entities: Node2D

## The ground tiles. We can check the position we're trying to put an entity down on
## to see if the mouse is over the tilemap.
var _ground: TileMapLayer

## The player entity. We can use it to check the distance from the mouse to prevent
## the player from interacting with entities that are too far away.
var _player: Player

## The variable below keeps track of the current deconstruction target cell. If the mouse moves
## to another cell, we can abort the operation by checking against this value.
var _current_deconstruct_location: Vector2i = Vector2i.ZERO


@onready var _deconstruct_timer: Timer = %DesconstructTimer


func _process(delta: float) -> void:
	var has_placeable_blueprint: bool = _gui.blueprint and _gui.blueprint.placeable
	# If we have a blueprint in hand, keep it updated and snapped to the grid if outside inventory
	if has_placeable_blueprint and not _gui.mouse_in_gui:
		_move_blueprint_in_world(local_to_map(get_global_mouse_position()))


## Here's our setup() function. It sets the placer up with the data that it needs to function,
## and adds any pre-placed entities to the tracker.
func setup(gui: GameGUI, tracker: EntityTracker, ground: TileMapLayer, flat_entities: Node2D, player: CharacterBody2D) -> void:
	# We use the function to initialize our private references. As mentioned before, this approach
	# makes refactoring easier, as the EntityPlacer doesn't need hard-coded paths to the EntityTracker,
	# GroundTiles, and Player nodes.
	_gui = gui
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
	var has_placeable_blueprint: bool = _gui.blueprint and _gui.blueprint.placeable

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
	var is_on_ground: bool = _ground.get_cell_source_id(cellv) == 0

	# When left-clicking, we use all our boolean variables to check the player can place an entity.
	# Using variables with clear names helps to write code that reads *almost* like English.
	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				_place_entity(cellv)
				_update_neighboring_flat_entities(cellv)
		# If we are not holding onto a blueprint and we click on an occupied
		# cell in range, and the entity is part of the GUI_ENTITIES, then call
		# GUI's `open_entity_gui()`.
		elif cell_is_occupied and is_close_to_player:
			var entity := _tracker.get_entity_at(cellv)
			if entity and entity.is_in_group(Types.GUI_ENTITIES):
				_gui.open_entity_gui(entity)
				_clear_hover_entity(cellv)

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
			if not _gui.mouse_in_gui:
				_move_blueprint_in_world(cellv)
		else:
			_update_hover(cellv)


	# When the user presses the drop button and we are holding a blueprint, we would
	# drop the entity as a dropable entity that the player can pick up.
	# For testing purposes, the following code clears the blueprint from the active slot instead.
	elif event.is_action_pressed("drop") and _gui.blueprint:
		if is_on_ground:
			_drop_entity(_gui.blueprint, global_mouse_position)
			_gui.blueprint = null
	## Rotate the blueprint's power indicator if it has one
	elif event.is_action_pressed("rotate_blueprint") and _gui.blueprint:
		_gui.blueprint.rotate_blueprint()


## Moves the active blueprint in the world according to mouse movement,
## and tints the blueprint based on whether the tile is valid.
func _move_blueprint_in_world(cellv: Vector2i) -> void:
	# Snap the blueprint's position to the mouse with an offset
	#_gui.blueprint.global_position = map_to_local(cellv)# + POSITION_OFFSET

	# Set the blueprint's position and scale back to origin
	_gui.blueprint.display_as_world_entity()

		# Snap the blueprint's position to the mouse with an offset, transformed into
	# viewport coordinates using `Transform2D.xform()`.
	_gui.blueprint.global_position = get_viewport_transform() * map_to_local(cellv)# + POSITION_OFFSET

	# Determine each of the placeable conditions
	var is_close_to_player: bool = (
		get_global_mouse_position().distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	var is_on_ground: bool = _ground.get_cell_source_id(cellv) == 0
	var cell_is_occupied: bool = _tracker.is_cell_occupied(cellv)

	# Tint according to whether the current tile is valid or not.
	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_gui.blueprint.modulate = Color.WHITE
	else:
		_gui.blueprint.modulate = Color.RED

	if _gui.blueprint is WireBlueprint:
		WireBlueprint.set_sprite_for_direction(_gui.blueprint.sprite, _get_powered_neighbors(cellv))


## Places the entity corresponding to the active `_blueprint` in the world at the specified
## location, and informs the `EntityTracker`.
func _place_entity(cellv: Vector2i) -> void:
	# Use the blueprint we prepared in _ready to instance a new entity.
	var new_entity: Entity = Library.entities[_gui.blueprint.type].instantiate()

	# Add it to the tilemap as a child so it gets sorted properly
	if _gui.blueprint is WireBlueprint:
		var directions: int = _get_powered_neighbors(cellv)
		_flat_entities.add_child(new_entity)
		WireBlueprint.set_sprite_for_direction(new_entity.sprite, directions)
	else:
		add_child(new_entity)

	# Snap its position to the map, adding `POSITION_OFFSET` to get the center of the grid cell.
	new_entity.global_position = map_to_local(cellv)# + POSITION_OFFSET

	# Call `setup()` on the entity so it can use any data the blueprint holds to configure itself.
	new_entity._setup(_gui.blueprint)

	# Register the new entity in the `EntityTracker` so all the signals can go up, as with systems.
	_tracker.place_entity(new_entity, cellv)

	if _gui.blueprint.stack_count == 1:
		_gui.destroy_blueprint()
	else:
		_gui.blueprint.stack_count -= 1
		_gui.update_label()


# Marks the `cell` as hovered if it's within the player's range.
func _update_hover(cellv: Vector2i) -> void:
	var is_close_to_player: bool = (
		get_global_mouse_position().distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	# If the cell contains an entity and it's in range, we mark it as hovered.
	if _tracker.is_cell_occupied(cellv) and is_close_to_player:
		_hover_entity(cellv)
	else:
		_clear_hover_entity(cellv)


## Marks the `cellv`'s entity as hovered and emits the `hovered_over_entity`
## signal.
func _hover_entity(cellv: Vector2i) -> void:
	var entity: Entity = _tracker.get_entity_at(cellv)
	Events.hovered_over_entity.emit(entity)


## Clears any hovered entity and signals the tooltip that we have nothing
## under the mouse.
func _clear_hover_entity(cellv: Vector2i) -> void:
	Events.hovered_over_entity.emit(null)


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
	# Get the blueprint in the player's hand currently.
	var blueprint_in_hand: BlueprintEntity = _gui.blueprint

	# Check the entity we're trying to deconstruct.
	var entity: Entity = _tracker.get_entity_at(cellv)

	# If it has a deconstruct filter property, and the blueprint we're holding
	# in our hand is part of the filter, then we can proceed. Otherwise, return
	# so we don't deconstruct it.
	if not entity.deconstruct_filter.is_empty():
		if not blueprint_in_hand:
			return
		if not blueprint_in_hand.type in entity.deconstruct_filter:
			return


	# We connect to the timer's `timeout` signal. We pass in the targeted tile as a
	# bind argument and make sure that the signal disconnects after emitting once
	# using the CONNECT_ONESHOT flag. This is because once the signal has triggered,
	# we do not want to have to disconnect manually. Once the timer ends, the deconstruct
	# operation ends.

	# We call the `_finish_deconstruct()` function when the timer times out. We'll code it next.
	_deconstruct_timer.timeout.connect(_finish_deconstruct.bind(cellv), CONNECT_ONE_SHOT)

	# Set a modifier if it's a tool, otherwise keep the standard modifier
	var modifier: float = 1.0 if not blueprint_in_hand is ToolEntity else 1.0 / blueprint_in_hand.tool_speed

	var deconstruct_bar: TextureProgressBar = _gui.deconstruct_bar

	# Just like we did it with the DragPreview, we need to transform the mouse's
	# position to translate it from the GUI canvas layer.
	deconstruct_bar.global_position = (
		get_viewport_transform() * event_position + POSITION_OFFSET
	)

	deconstruct_bar.show()

	var _deconstruct_tween: Tween = create_tween()
	deconstruct_bar.value = 0.0
	_deconstruct_tween.tween_property(deconstruct_bar, "value", 1, DECONSTRUCT_TIME * modifier)

	# We then start the timer and store the cell we're targeting, which allows us to cancel
	# the operation if the player's mouse moves to another cell.
	_deconstruct_timer.start(DECONSTRUCT_TIME * modifier)

	_current_deconstruct_location = cellv


## Finish the deconstruction and delete the entity from the game world.
func _finish_deconstruct(cellv: Vector2i) -> void:
	# This function will drop the deconstructed entity as a pickup item,
	# but we haven't implemented an inventory yet, so we only remove the entity.
	var entity: Entity = _tracker.get_entity_at(cellv)
	# We convert the map position to a global position.
	var location: Vector2 = map_to_local(cellv)

	# Drop the entities registered
	var drop_blueprint: PackedScene = Library.blueprints[entity.drop_type]
	for _i in entity.drop_count:
		_drop_entity(drop_blueprint.instantiate(), location)

	# We check if the entity has a GUI component and look for its inventories.
	if entity.is_in_group(Types.GUI_ENTITIES):
		var inventories: Array[InventoryBar] = _gui.find_inventory_bars_in(_gui.get_gui_component_from(entity))

		# We then loop over all inventories to find all the items they contain.
		var inventory_items: Array[BlueprintEntity] = []
		for inventory in inventories:
			inventory_items += inventory.get_inventory()

		# And we drop them
		for item in inventory_items:
			for i in range(item.stack_count):
				# Duplicate because we're about to remove the original blueprint from the inventory
				# If we don't do it, blueprint will become null on the ground item
				_drop_entity(item.duplicate(), location)

	_tracker.remove_entity(cellv)
	_update_neighboring_flat_entities(cellv)
	_gui.deconstruct_bar.hide()


## Creates a new ground item with the given blueprint and sets it up at the
## deconstructed entity's location.
func _drop_entity(blueprint_entity: BlueprintEntity, location: Vector2) -> void:
	# We instance a new ground item, add it, and set it up
	var ground_item: = GroundItemScene.instantiate()
	add_child(ground_item)
	ground_item.setup(blueprint_entity, location)


func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", _finish_deconstruct):
		_deconstruct_timer.disconnect("timeout", _finish_deconstruct)
	_deconstruct_timer.stop()

	_gui.deconstruct_bar.hide()
