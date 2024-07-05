class_name ElectricFurnaceGUI extends FurnaceGUI

## Like with the Stirling engine, when the system isn't being fed with enough
## electricity, we can slow it down with a speed parameter by affecting the
## tween's playback speed.
func update_speed(speed: float) -> void:
	if not is_inside_tree():
		return

	work_tween.set_speed_scale(speed)


func setup(gui: Control) -> void:
	input_container.setup(gui)
	output_container.setup(gui)
	output_slot = output_container.slots[0]


func update_labels() -> void:
	input_container.update_labels()
	output_container.update_labels()
