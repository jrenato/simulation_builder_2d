extends MarginContainer

@export var crafting_item_scene: PackedScene

var gui: Control

@onready var recipe_items_container: VBoxContainer = %RecipeItemsContainer


## We use this function to get a reference to the main GUI node, which, in turn,
## will give us functions to access the inventory.
func setup(_gui: Control) -> void:
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
		recipe_item.setup(recipe)
