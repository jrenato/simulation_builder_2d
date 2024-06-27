class_name QuickBarInventorySlot extends VBoxContainer

@onready var inventory_slot: InventorySlot = %InventorySlot


## Forwards the call to `setup()` to the inventory slot
func setup(gui: Control) -> void:
	inventory_slot.setup(gui, [], [])
