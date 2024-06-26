## Component that can provide connected machines with electricity.
## Add it as a child node of to machines that produce energy.
class_name PowerSource extends Node

## Signal for the power system to notify the component that it took
## a certain amount of power from the power source. Allows entities to react accordingly.
## For example, a battery can lower its stored amount or a generator can burn a tick of fuel.
signal power_updated(power_draw: float, delta: float)

## The maximum amount of power the machine can provide in units per tick.
@export var power_amount: float = 10.0

## The possible directions for power to come `out` of the machine.
## The default value, 15, makes it omnidirectional.
## The FLAGS export hint below turns the value display in the Inspector into a checkbox list.
## RIGHT = 1, DOWN = 2, LEFT = 4, UP = 8 
@export_flags("RIGHT:1", "DOWN:2", "LEFT:4", "UP:8") var output_direction: int = 15
## How efficient the machine currently is. For instance, a machine that has no work
## to do has an efficiency of `0` where one that has a job has an efficiency of `1`.
var efficiency: float = 0.0


## Returns a float indicating the possible power multiplied by the current efficiency.
func get_effective_power() -> float:
	return power_amount * efficiency
