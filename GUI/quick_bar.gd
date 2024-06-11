class_name QuickBar extends InventoryBar


## We override _make_panels() from the parent class to configure the label.
func _make_slots() -> void:
	# We create all the item slots as in the parent class, except we're going to instance
	# `QuickbarInventoryPanel`. Make a new item slot and add it as a child.
	for i in slot_count:
		var slot: QuickBarInventorySlot = InventorySlotScene.instantiate()
		add_child(slot)
		# The inventory bar expects a list of `IventoryPanel` nodes to function.
		# So we make sure we get that node from each `QuickbarInventoryPanel` and
		# append it to the `panels`.
		slots.append(slot.get_node("InventorySlot"))

		# Here's where we set the shortcut number on the label.
		var index := wrapi(i + 1, 0, 10)
		slot.get_node("Label").text = str(index)
