class_name GUIComponent extends Node

## We'll bubble up signals from `BaseMachineGUI` to make it easier to connect to
## them.
signal gui_status_changed
signal gui_opened
signal gui_closed

## This is the scene we'll instance and save in the `gui` variable.
@export var GuiWindow: PackedScene

## This will store the instanced interfact for the machine.
var gui: BaseMachineGUI


func _ready() -> void:
	# We must assign a scene to the `GuiWindow` for this code to work.
	assert(GuiWindow, "You must assign a scene to the the Gui Window property.")
	gui = GuiWindow.instantiate()

	# We connect to the new instance's signals, but instead of using a custom
	# function, we emit the signals directly with a lambda function.
	# Doing this forwards signals automatically.
	gui.gui_status_changed.connect(func(): gui_status_changed.emit())
	gui.gui_opened.connect(func(): gui_opened.emit())
	gui.gui_closed.connect(func(): gui_closed.emit())


func _exit_tree() -> void:
	if gui:
		# Because the gui instance is not likely to be in the scene tree when we
		# quit the game or go back to the main menu, it will not be
		# automatically be cleaned up in memory.
		#
		# Freeing it when this component exits the scene tree saves us from
		# having a memory leak.
		gui.queue_free()
