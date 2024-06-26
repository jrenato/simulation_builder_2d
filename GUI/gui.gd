extends CenterContainer

## Each of the action as listed in the input map. We place them in an array so we
## can iterate over each one.
const QUICKBAR_ACTIONS := [
	"quickbar_1",
	"quickbar_2",
	"quickbar_3",
	"quickbar_4",
	"quickbar_5",
	"quickbar_6",
	"quickbar_7",
	"quickbar_8",
	"quickbar_9",
	"quickbar_0"
]

## Prefills the player inventory with objects from this dictionary
@export var debug_items: Array[DebugItem] = []

## A reference to the inventory that belongs to the 'mouse'. It is a property
## that gives indirect access to DragPreview's blueprint through its getter
## function. No one needs to know that it is stored outside of the GUI class.
var blueprint: BlueprintEntity:
	set = _set_blueprint,
	get = _get_blueprint

## If `true`, it means the mouse is over the `GUI` at the moment.
var mouse_in_gui: bool = false

## The currently opened entity GUI.
var _open_gui: Control

## We use the reference to the drag preview in the setter and getter functions.
@onready var _drag_preview: Control = %DragPreview
@onready var deconstruct_bar: TextureProgressBar = %DeconstructProgressBar
@onready var _inventory_container: HBoxContainer = %InventoryContainer
@onready var _quickbar_container: PanelContainer = %QuickBarContainer
@onready var inventory: Inventory = %InventoryWindow
@onready var quickbar: QuickBar = %QuickBar
@onready var crafting: Crafting = %CraftingGUI

@onready var is_open: bool = inventory.visible


func _ready() -> void:
	Events.entered_pickup_area.connect(_on_player_entered_pickup_area)
	inventory.inventory_changed.connect(_on_inventory_changed)
	quickbar.inventory_changed.connect(_on_inventory_changed)
	# Here, we'll set up any GUI systems that require knowledge of the GUI node.
	# We'll define `InventoryWindow.setup()` in the next lesson.
	inventory.setup(self)
	quickbar.setup(self)
	crafting.setup(self)
	add_debug_items()
	_close_inventories()


func add_debug_items() -> void:
	# ----- Debug system -----
	# We loop over all the keys in the `debug_items` dictionary and ensure they exist in the `Library`.
	for debug_item in debug_items:
		if not Library.blueprints.has(debug_item.type):
			continue

		# If so, we instantiate the item and set its stack count to the value dictionary's value.
		var item_instance: Node = Library.blueprints[debug_item.type].instantiate()
		item_instance.stack_count = min(item_instance.stack_size, debug_item.amount)

		# We then try to add it to the inventory and if it's full, we free the leftover blueprint.
		if not add_to_inventory(item_instance):
			item_instance.queue_free()


func _process(delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	# If the mouse is inside the GUI rect and the GUI is open, set it true.
	var mouse_in_inventory: bool = is_open and _inventory_container.get_rect().has_point(mouse_position)
	var mouse_in_quickbar: bool = _quickbar_container.get_rect().has_point(mouse_position)
	mouse_in_gui = mouse_in_inventory or mouse_in_quickbar


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if is_open:
			_close_inventories()
		else:
			_open_inventories()
	else:
		for i in QUICKBAR_ACTIONS.size():
			# If the action matches with one of our quickbar actions, we call
			# a function that simulates a mouse click at its location.
			if InputMap.event_is_action(event, QUICKBAR_ACTIONS[i]) and event.is_pressed():
				_simulate_input(quickbar.slots[i])
				# We break out of the loop, since there cannot be more than one
				# action pressed in the same event. We'd be wasting resources otherwise.
				break


## Simulates a mouse click at the location of the panel.
func _simulate_input(slot: InventorySlot) -> void:
	# Create a new InputEventMouseButton and configure it as a left button click.
	var input := InputEventMouseButton.new()
	input.button_index = MOUSE_BUTTON_LEFT
	input.pressed = true

	# Provide it directly to the panel's `_gui_input()` function, as we don't care
	# about the rest of the engine intercepting this event.
	slot._gui_input(input)


## Forwards the `destroy_blueprint()` call to the drag preview.
func destroy_blueprint() -> void:
	_drag_preview.destroy_blueprint()


## Forwards the `update_label()` call to the drag preview.
func update_label() -> void:
	_drag_preview.update_label()


## Checks the player's inventory and compares the total count of items with
## a given `item_id`.
## Returns `true` if it's equal or greater than the specified `amount`.
func is_in_inventory(item_type: Library.TYPE, amount: int) -> bool:
	# Get all panels that have the given item by name.
	var existing_stacks: Array[InventorySlot] = find_slots_with(item_type)
	if existing_stacks.is_empty():
		return false

	# If we have them, iterate over each one and total them up.
	var total := 0
	for stack in existing_stacks:
		total += stack.held_item.stack_count
	return total >= amount


## Setter that forwards setting the blueprint to `DragPreview.blueprint`.
func _set_blueprint(value: BlueprintEntity) -> void:
	if not is_inside_tree():
		await ready
	_drag_preview.blueprint = value


## Getter that returns the DragPreview's blueprint.
func _get_blueprint() -> BlueprintEntity:
	return _drag_preview.blueprint


## Shows the inventory window, crafting window
# We add a new `open_crafting` argument to the function to optionally hide the
# crafting recipe list.
# Making `open_crafting` an optional variable that defaults to `true` means we
# don't have to go back to other functions and change them.
func _open_inventories(open_crafting: bool = true) -> void:
	is_open = true
	inventory.visible = true
	inventory.claim_quickbar(quickbar)
	# If we should open the crafting window, then make it visible and update its
	# recipes. Otherwise, we leave it hidden.
	if open_crafting:
		crafting.visible = true
		crafting.update_recipes()


## Hides the inventory window, crafting window, and any currently open machine GUI
func _close_inventories() -> void:
	is_open = false
	inventory.visible = false
	if crafting.visible:
		crafting.visible = false
	_claim_quickbar()
	# If we have an open gui, then we remove it from the scene tree and clear
	# the `_open_gui` property.
	# We don't free it: that's the component's job.
	if _open_gui:
		inventory.inventory_bars.remove_child(_open_gui)
		_open_gui = null


## Removes the quickbar from its current parent and puts it back under the
## quickbar's margin container
func _claim_quickbar() -> void:
	quickbar.get_parent().remove_child(quickbar)
	_quickbar_container.add_child(quickbar)


## Returns an array of inventory slots containing a held item that has
## the type that matches the provided type from the player inventory and quick-bar.
func find_slots_with(item_type: Library.TYPE) -> Array[InventorySlot]:
	var existing_stacks: Array[InventorySlot] = (
		quickbar.find_slots_with(item_type)
		+ inventory.find_slots_with(item_type)
	)

	return existing_stacks


## Tries to add the blueprint to the inventory, starting with existing item
## stacks and then to an empty panel in the quickbar, then in the main inventory.
## Returns true if it succeeds.
func add_to_inventory(item: BlueprintEntity) -> bool:
	# If the item is already in the scene tree, remove it first.
	if item.get_parent() != null:
		item.get_parent().remove_child(item)

	if quickbar.add_to_first_available_inventory(item):
		return true

	return inventory.add_to_first_available_inventory(item)


## Returns a `GUIComponent` from the scene tree of an entity.
## Returns `null` if none is found.
func get_gui_component_from(entity: Node) -> GUIComponent:
	for child in entity.get_children():
		if child is GUIComponent:
			return child

	return null


## Adds the entity's GUI to the inventory window and displays the inventory
## window.
func open_entity_gui(entity: Entity) -> void:
	var component: GUIComponent = get_gui_component_from(entity)
	if not component:
		return

	# If the inventory window is already open, we close it first. This ensures
	# we close any currently opened gui from another entity first.
	if is_open:
		_close_inventories()

	_open_gui = component.gui

	# If the gui is not already in the inventory window, we add it. We also
	# raise the child to the highest tree position so it appears above the
	# inventory, instead of below it.
	# That's necessary because the inventory uses a VBoxContainer.
	if not _open_gui.get_parent() == inventory.inventory_bars:
		inventory.inventory_bars.add_child(_open_gui)
		inventory.inventory_bars.move_child(_open_gui, 0)

	# We make sure to call `BaseMachineGUI.setup()`, then call
	# `open_inventories()`, but without the crafting window.
	_open_gui.setup(self)
	# See below as we add a new argument to `_open_inventories()`.
	_open_inventories(false)


## Tries to add the ground item detected by the player collision into the player's
## inventory and trigger the animation for it.
func _on_player_entered_pickup_area(item: GroundEntity, player: CharacterBody2D) -> void:
	if not (item and item.blueprint):
		return

	# We get the current amount inside the stack. It's possible for there to be
	# no space for the entire stack, but we could still pick up parts of the stack.
	var amount: int = item.blueprint.stack_count

	# Attempts to add the item to existing stacks and available space.
	if add_to_inventory(item.blueprint):
		# If we succeed, we play the `do_pickup()` animation, disable collision, etc.
		item.do_pickup(player)
	else:
		# If the attempt failed, we calculate if the stack is smaller than it
		# used to be before we tried picking it up.
		if item.blueprint.stack_count < amount:
			# If so, we need to create a new duplicate ground item whose job is to animate
			# itself flying to the player.
			var new_item: GroundEntity = item.duplicate()

			# We need to use `call_deferred` to delay the new item by a frame because
			# we disable the shape's collision so it can't be picked up twice.
			#
			# As the physics engine is currently busy dealing with the collision
			# with the player's area and Godot doesn't allow us to change
			# collision states when its physics engine is busy, we need to wait
			# so it won't complain or cause errors.
			item.get_parent().call_deferred("add_child", new_item)
			new_item.call_deferred("setup", item.blueprint)
			new_item.call_deferred("do_pickup", player)


func _on_inventory_changed(slot: InventorySlot, held_item: BlueprintEntity) -> void:
	crafting.update_recipes()
