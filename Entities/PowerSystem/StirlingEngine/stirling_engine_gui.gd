extends BaseMachineGUI

## A reference to the fuel inside of the inventory bar, instead of having to
## access the inventory bar and get one of its held items. This makes it easier
## for the entity to access.
var fuel: BlueprintEntity

@onready var fuel_bar: ProgressBar = %FuelProgressBar
@onready var fuel_container: InventoryBar = %InventoryBar


func _ready() -> void:
	fuel_container.inventory_changed.connect(_on_inventory_bar_inventory_changed)


## Sets the shader to the provided amount to fill or empty the bar.
func set_fuel(amount: float) -> void:
	if fuel_bar:
		#fuel_bar.material.set_shader_param("fill_amount", amount)
		fuel_bar.value = amount


## Sets up the inventory bar that holds the fuel.
func setup(gui: Control) -> void:
	fuel_container.setup(gui)


## Ensures that the inventory bar is up to date when we consume a piece of fuel.
## The number on the stack should go down.
func update_labels() -> void:
	fuel_container.update_labels()


## When the inventory bar changes, we can bubble up the signal and warn the
## entity.
func _on_inventory_bar_inventory_changed(slot: InventorySlot, held_item: BlueprintEntity) -> void:
	# Store the item in the fuel variable so the entity can access it.
	fuel = held_item
	gui_status_changed.emit()
