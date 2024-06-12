class_name InventoryBar extends HBoxContainer

## Emitted whenever a panel's item changed.
signal inventory_changed(slot: InventorySlot, held_item: BlueprintEntity)

## A scene resource for the inventory slots, a scene we'll create next and that represents
## individual item slots.
@export var InventorySlotScene: PackedScene

## How many slots to create as children of the bar.
@export var slot_count: int = 10

## An array of references to the slots we create so we can refer to them and
## check their contents later.
var slots: Array[InventorySlot] = []


func _ready() -> void:
	# Create the bar's slots first thing.
	_make_slots()


## Sets up each of the inventory panels and connects to their `held_item_changed` signal.
func setup(gui: Control) -> void:
	# For each panel we've created in `_ready()`, we forward the reference to the GUI node
	# and connect to their signal.
	for slot in slots:
		slot.setup(gui)
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


## Bubbles up the signal from the inventory bar up to the inventory window.
func _on_slot_held_item_changed(slot: InventorySlot, held_item: BlueprintEntity) -> void:
	inventory_changed.emit(slot, held_item)
