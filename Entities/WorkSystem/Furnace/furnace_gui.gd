extends BaseMachineGUI

# Reference to the ore item in the input inventory bar.
var input: BlueprintEntity
# Reference to the fuel item in the fuel inventory bar.
var fuel: BlueprintEntity

# We grab the output panel to work with its inventory directly.
# This is because the inventory bar would normally check the item filters, which we
# want to bypass without having to code a workaround.
var output_slot: Panel

var work_tween: Tween

# Those are references to all the nodes we'll need to access in the script.
@onready var input_container: InventoryBar = %InputInventoryBar
@onready var fuel_container: InventoryBar = %FuelInventoryBar
@onready var output_container: InventoryBar = %OutputInventoryBar
@onready var fuel_bar: ProgressBar = %FuelProgressBar
@onready var work_bar: TextureProgressBar = %WorkProgressBar


func _ready() -> void:
	input_container.inventory_changed.connect(_on_input_inventory_bar_inventory_changed)
	fuel_container.inventory_changed.connect(_on_fuel_inventory_bar_inventory_changed)


## We'll call this function to start the crafting animation (arrow filling up).
## The function initiates a tween animation lasting `time` seconds.
func work(time: float) -> void:
	# Tween does not work if it is not in the scene tree, so we need to check if
	# the GUI is open or not before we start animating.
	if not is_inside_tree():
		return

	# We tween the work bar progress
	if work_tween:
		work_tween.kill()

	work_tween = create_tween()
	work_tween.tween_method(_advance_work_time, 0.0, 1.0, time)


## Stops the tween animation and resets the arrow fill amount.
func abort() -> void:
	if work_tween:
		work_tween.kill()
	work_bar.value = 0


## Updates the *fuel* bar's `fill_amount` shader parameter.
func set_fuel(amount: float) -> void:
	fuel_bar.value = amount


## If the tween is already animating, seek to the current amount of time.
## We use this when we start animating, close the inventory, and then open it
## again later. This makes sure the tween is updated to the amount of time
## left crafting.
func seek(time: float, initial_value: float) -> void:
	if work_tween:
		work_tween.kill()

	work_tween = create_tween()
	work_tween.tween_method(_advance_work_time, initial_value, 1.0, time)


## Sets up all inventory slots.
func setup(gui: Control) -> void:
	input_container.setup(gui)
	fuel_container.setup(gui)
	output_container.setup(gui)
	# We manually access the item panel in the output inventory bar to manually
	# insert crafted ingots in it.
	output_slot = output_container.slots[0]


## Sets a newly crafted item as the output panel's item, or adds it to the
## existing crafted item stack.
func grab_output(item: BlueprintEntity) -> void:
	# If there's no item in the output slot, we assign it.
	if not output_slot.held_item:
		output_slot.held_item = item
	# If there's already an item, we increase its stack count.
	else:
		if output_slot.held_item.type == item.type:
			output_slot.held_item.stack_count += item.stack_count

		item.queue_free()
	output_container.update_labels()


## Force all panel labels to update.
func update_labels() -> void:
	input_container.update_labels()
	fuel_container.update_labels()
	output_container.update_labels()


## Sets the *arrow*'s value so it fills up. Called by the tween node.
func _advance_work_time(amount: float) -> void:
	work_bar.value = amount


# When the player changes the item in the input inventory slot, we store a
# reference to the item and emit the `gui_status_changed` signal.
func _on_input_inventory_bar_inventory_changed(_slot: InventorySlot, held_item: BlueprintEntity) -> void:
	input = held_item
	gui_status_changed.emit()


# We do the same with the fuel item slot.
func _on_fuel_inventory_bar_inventory_changed(_slot: InventorySlot, held_item: BlueprintEntity) -> void:
	fuel = held_item
	gui_status_changed.emit()
