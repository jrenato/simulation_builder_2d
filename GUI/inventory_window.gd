extends MarginContainer

## We use this signal to notify the GUI system that the inventory has changed.
signal inventory_changed(slot: InventorySlot, held_item: BlueprintEntity)

## The main GUI node so we can use it to transmit messages and function calls.
var gui: Control

## Get the control that holds the inventory bars. We get this node because we can
## assign the quick-bar to it later.
@onready var inventory_bars: VBoxContainer = %InventoryBars

## We get each of the inventory bars in an array so we can iterate over them.
@onready var inventories: Array[Node]= inventory_bars.get_children()


## Here, we define the missing `setup()` function we called from `GUI.gd` in the previous lesson.
## It forwards the setup call to the inventory bars, so they can setup their panels.
func setup(_gui: Control) -> void:
	gui = _gui
	for bar in inventories:
		bar.setup(gui)

	var engine: BlueprintEntity = Library.blueprints[Library.TYPE.STIRLING].instantiate()
	engine.stack_count = 4
	var battery: BlueprintEntity = Library.blueprints[Library.TYPE.BATTERY].instantiate()
	battery.stack_count = 4
	inventories[0].slots[0].held_item = engine
	inventories[0].slots[1].held_item = battery


## Whenever we receive the `inventory_changed` signal, bubble up the signal from the inventory bars.
func _on_inventory_bar_inventory_changed(slot: InventorySlot, held_item: BlueprintEntity) -> void:
	inventory_changed.emit(slot, held_item)
