class_name InventoryBar extends HBoxContainer

## A scene resource for the inventory slots, a scene we'll create next and that represents
## individual item slots.
@export var InventorySlotScene: PackedScene

## How many slots to create as children of the bar.
@export var slot_count: int = 10

## An array of references to the slots we create so we can refer to them and
## check their contents later.
var slots := []


func _ready() -> void:
	# Create the bar's slots first thing.
	_make_slots()


## Creates several inventory panel instances as a child of this horizontal bar.
## Adds them to the `slots` object variable.
func _make_slots() -> void:
	# For each slot
	for _i in slot_count:
		# Instance an InventorySlot, add it as a child, and add it to the `slots` array.
		var slot: InventorySlot = InventorySlotScene.instantiate()
		add_child(slot)
		slots.append(slot)
