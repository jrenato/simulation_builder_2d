extends BaseMachineGUI


func setup(_gui: GameGUI) -> void:
	for inventory in $VBoxContainer.get_children():
		inventory.setup(_gui)
