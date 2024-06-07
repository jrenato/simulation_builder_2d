class_name BatteryEntity extends Entity

@export var max_storage: float = 1000.0

var stored_power: float = 0.0:
	set(value):
		# We set the stored power and prevent it from becoming negative.
		stored_power = max(value, 0)
		_update_stored_power()

@onready var power_source: PowerSource = %PowerSource
@onready var power_receiver: PowerReceiver = %PowerReceiver
@onready var indicator_sprite: Sprite2D = %IndicatorSprite2D


func _ready() -> void:
	power_source.power_updated.connect(_on_power_source_power_updated)
	power_receiver.power_received.connect(_on_power_receiver_power_received)

	# If the source is not omnidirectional:
	if power_source.output_direction != 15:
		# Set the receiver direction to the _opposite_ of the source.
		# The ^ is the XOR (exclusive or) operator.
		# If | returns 1 if either bit is 1, and & returns 1 if both bits are 1,
		# ^ returns 1 if the bits _do not_ match.

		# This inverts the direction flags, making each direction that's not an output
		# a valid input to receive energy.
		power_receiver.input_direction = 15 ^ power_source.output_direction


## The setup function fetches the direction from the blueprint, applies it
## to the source, and inverts it for the receiver with the XOR operator (^).
func _setup(blueprint: BlueprintEntity) -> void:
	power_source.output_direction = blueprint.power_direction.output_directions
	power_receiver.input_direction = 15 ^ power_source.output_direction


## Set the efficiency in source and receiver based on the amount of stored power.
func _update_stored_power() -> void:
	# Wait until the entity is ready to ensure we have access to the `receiver` and the `source` nodes.
	if not is_inside_tree():
		await ready

	# Set the receiver's efficiency.
	power_receiver.efficiency = (
		0.0
		# If the battery is full, set it to 0. We don't want it to draw more power.
		if stored_power >= max_storage
		# If the battery is less than full, set it to between 1 and
		# the percentage of how empty the battery is.
		# This makes the battery fill up slower as it approaches being full.
		else min((max_storage - stored_power) / power_receiver.power_required, 1.0)
	)

	# Set the source efficiency to `0` if there is no power. Otherwise, we set it to a percentage of how full
	# the battery is. A battery that has more power than it must provide returns one, whereas a battery
	# that has less returns some percentage of that.
	power_source.efficiency = (0.0 if stored_power <= 0 else min(stored_power / power_source.power_amount, 1.0))
	indicator_sprite.material.set_shader_parameter("amount", stored_power / max_storage)


## Sets the stored power using the setter based on the received amount of power per second.
func _on_power_receiver_power_received(amount: float, delta: float) -> void:
	stored_power = stored_power + amount * delta


## Sets the stored power using the setter based on the amount of power provided per second.
func _on_power_source_power_updated(power_draw: float, delta: float) -> void:
	stored_power = stored_power - min(power_draw, power_source.get_effective_power()) * delta
