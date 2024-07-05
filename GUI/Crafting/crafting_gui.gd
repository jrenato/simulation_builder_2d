class_name Crafting extends MarginContainer

@export var crafting_item_scene: PackedScene

var gui: Control

@onready var recipe_items_container: VBoxContainer = %RecipeItemsContainer


## We use this function to get a reference to the main GUI node, which, in turn,
## will give us functions to access the inventory.
func setup(_gui: GameGUI) -> void:
	gui = _gui


## The main function that forces an update of all recipes based on what items
## are available in the player's inventory.
func update_recipes() -> void:
	# We free all existing recipes to start from a clean state.
	for child in recipe_items_container.get_children():
		child.queue_free()

	# We loop over every available recipe.
	for recipe in Library.recipes.values():
		# We default to true, and then iterate over each item. If at any point
		# it turns out false, then we can skip the item.
		var can_craft: bool = true

		# For each required material in the recipe, we ensure the player has enough of it.
		# If not, they can't craft the item and we move to the next recipe.
		for recipe_input in recipe.inputs:
			if not gui.is_in_inventory(recipe_input.type, recipe_input.amount):
				can_craft = false
				break

		if not can_craft:
			continue

		# We instantiate the recipe item and add it to the scene tree.
		var recipe_item: PanelContainer = crafting_item_scene.instantiate()
		recipe_items_container.add_child(recipe_item)

		# And we use the recipe to set up the recipe item.
		# It'll handle the name, texture, and sprite region information.
		recipe_item.recipe = recipe
		recipe_item.recipe_activated.connect(_on_recipe_activated)

	Events.hovered_over_entity.emit(null)


## Crafts the output item by consuming the recipe's inputs from the player
## inventory.
func _on_recipe_activated(recipe: Recipe) -> void:
	# We loop over every input and find inventory panels containing this item.
	for input in recipe.inputs:
		var slots: Array = gui.find_slots_with(input.type)
		var count: int = input.amount

		# We then loop over the panels and update their count.
		for slot in slots:
			# If there is enough in the stack, we reduce it by the required
			# amount.
			if slot.held_item.stack_count >= count:
				slot.held_item.stack_count -= count
				# Since we had enough items, make count 0
				count = 0
			# If there isn't enough, we reduce the required count by how many there
			# are, then set the stack to 0.
			else:
				count -= slot.held_item.stack_count
				slot.held_item.stack_count = 0

			# If the stack is now a size of 0, we delete it.
			if slot.held_item.stack_count == 0:
				slot.held_item.queue_free()
				slot.held_item = null

			# And we update the count label up to date if it hasn't been deleted.
			slot.update_label()

			# If count is now 0, then we no longer need to check any other panel
			if count == 0:
				break

	# Now that we've consumed all items, we can use the library to instance a
	# new blueprint for the new item, and add it to the player inventory.
	var item: BlueprintEntity = Library.blueprints[recipe.output_type].instantiate()
	item.stack_count = recipe.amount

	gui.add_to_inventory(item)
