class_name InventoryBar extends HBoxContainer

## Emitted whenever a panel's item changed.
signal inventory_changed(slot: InventorySlot, held_item: BlueprintEntity)

## A scene resource for the inventory slots, a scene we'll create next and that represents
## individual item slots.
@export var InventorySlotScene: PackedScene

## How many slots to create as children of the bar.
@export var slot_count: int = 10

## An array of types of possible items or categories of items the
## panels can accept
@export var item_filter: Array[Library.TYPE] = []

## Optionaly, a group can be used as filter
@export var group_filter: Array[Library.GROUP_TYPE] = []

## An array of references to the slots we create so we can refer to them and
## check their contents later.
var slots: Array[InventorySlot] = []

var is_setup: bool = false


func _ready() -> void:
	# Create the bar's slots first thing.
	_make_slots()


## Sets up each of the inventory panels and connects to their `held_item_changed` signal.
func setup(gui: GameGUI) -> void:
	if is_setup:
		return

	is_setup = true

	# For each panel we've created in `_ready()`, we forward the reference to the GUI node
	# and connect to their signal.
	for slot in slots:
		slot.setup(gui, item_filter, group_filter)
		slot.held_item_changed.connect(_on_slot_held_item_changed)


## Creates several inventory panel instances as a child of this horizontal bar.
## Adds them to the `slots` object variable.
func _make_slots() -> void:
	# For each slot
	for _i in slot_count:
		# Instance an InventorySlot, add it as a child, and add it to the `slots` array.
		var slot: InventorySlot = InventorySlotScene.instantiate()
		add_child(slot)
		slots.append(slot)


## Returns an array of inventory slots that have a held item that have
## the same type provided.
func find_slots_with(item_type: Library.TYPE) -> Array[InventorySlot]:
	var output: Array[InventorySlot] = []
	for slot in slots:
		# Check if there is an item and its type matches
		if slot.held_item and slot.held_item.type == item_type:
			output.push_back(slot)

	return output


## Tries to add the provided item to the first available empty space. Returns
## true if it succeeds.
func add_to_first_available_inventory(item: BlueprintEntity) -> bool:
	if not Library.is_valid_filter(item.type, item_filter, group_filter):
		return false

	for slot in slots:
		# If the slot already has an item and its type matches that of the item
		# we are trying to put in it, _and_ there is space for it, we merge the
		# stacks.
		if (
			slot.held_item
			and slot.held_item.type == item.type
			and slot.held_item.stack_count < slot.held_item.stack_size
		):
			var available_space: int = slot.held_item.stack_size - slot.held_item.stack_count

			# If there is not enough space, we reduce the item count by however
			# many we can fit onto it, then move on to the next slot.
			if item.stack_count > available_space:
				slot.held_item.stack_count += available_space
				slot.update_label()
				item.stack_count -= available_space
			# If there is enough space, we increment the stack, destroy the item, and 
			# report success.
			else:
				slot.held_item.stack_count += item.stack_count
				slot.update_label()
				item.queue_free()
				return true

		# If the slot is empty, then automatically put the item in it and report success.
		elif not slot.held_item:
			slot.held_item = item
			return true

	# There is no more available space in this inventory bar or it cannot pick up
	# the item. Report as much.
	return false


## Returns the combined inventory of all inventory panels.
func get_inventory() -> Array[BlueprintEntity]:
	var output: Array[BlueprintEntity] = []
	for slot in slots:
		if is_instance_valid(slot.held_item):
			output.push_back(slot.held_item)

	return output

## When we consume an item like fuel, we need a way to make sure the stack count
## is up to date.
## this helper function will keep the label up to date on its panel children.
func update_labels() -> void:
	for slot in slots:
		if slot.held_item:
			slot._update_label()


## Bubbles up the signal from the inventory bar up to the inventory window.
func _on_slot_held_item_changed(slot: InventorySlot, held_item: BlueprintEntity) -> void:
	inventory_changed.emit(slot, held_item)
