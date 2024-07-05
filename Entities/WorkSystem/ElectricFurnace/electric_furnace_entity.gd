extends FurnaceEntity

@onready var work_component: WorkComponent = %WorkComponent
@onready var gui_component: GUIComponent = %GUIComponent
@onready var power_receiver: PowerReceiver = %PowerReceiver


func _ready() -> void:
	work_component.work_enabled_changed.connect(_on_work_component_work_enabled_changed)
	work_component.work_done.connect(_on_work_component_work_done)
	work_component.work_accomplished.connect(_on_work_component_work_accomplished)
	gui_component.gui_status_changed.connect(_on_gui_component_gui_status_changed)
	gui_component.gui_opened.connect(_on_gui_component_gui_opened)
	power_receiver.received_power.connect(_on_power_receiver_received_power)


func _ready() -> void:
	# We always want the furnace to draw power, so it activates instantly when
	# it receives electricity and has a job to do.
	power.efficiency = 1.0


func _set_initial_speed() -> void:
	# Set the initial work speed to 0. We'll update it using power instead.
	work.work_speed = 0.0


func _consume_fuel(amount: float) -> void:
	# We have no fuel to consume, so we override the function to do nothing.
	pass


## As we need to keep the speed up to date as well as update the craft's status,
## we override the signal callback to pass the speed in.
func _on_GUIComponent_gui_opened() -> void:
	if work.is_enabled and work.work_speed > 0.0:
		gui.gui.work(work.current_recipe.time)
		gui.gui.update_speed(work.work_speed)
		gui.gui.seek(work.current_recipe.time - work.available_work)



func _on_power_receiver_received_power(amount: float, delta: float):
	# We calculate the work speed based on the amount of power required.
	#
	# If we only get 50% of the power we need, we'll still work at 50% capacity.
	#
	# The power system never sends more than we need, so we don't have to clamp
	# it to 1.
	var new_work_speed: float = amount / power.power_required

	gui.gui.update_speed(new_work_speed)
	work.work_speed = new_work_speed

	# If we have a positive power flow, set the fuel to 100%.
	if amount > 0:
		available_fuel = 1.0
	# Set up any work that needs doing (or is still ongoing)
	_setup_work()
	# Then reset the fake fuel to 0 so that, if power flow is cut off, we don't
	# keep smelting new ingots.
	available_fuel = 0
