extends PanelContainer

signal recipe_activated(recipe: Recipe)

## We store the property path for the custom panel in a constant for easy
## reference.
const CUSTOM_PANEL_PROPERTY: String = "theme_override_styles/panel"

@export var regular_style: StyleBoxFlat
@export var highlight_style: StyleBoxFlat

var recipe: Recipe: set = setup

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	var gui_size: float = ProjectSettings.get_setting("game_gui/inventory_slot_size")

	# Blueprint sprites are 100 pixels in size. We calcualte the desired scale
	# modifier by dividing the provided size by 100.
	var gui_scale := gui_size / 100.0

	# Then we can scale the sprite's size and the minimum size of the crafting
	# window based on a constant 300 pixels, our desired base width.
	texture_rect.scale = Vector2(gui_scale, gui_scale)
	custom_minimum_size = Vector2(300, 0) * gui_scale

	if regular_style:
		set(CUSTOM_PANEL_PROPERTY, regular_style)


## Sets up the sprite and label with the provided recipe data.
func setup(value: Recipe) -> void:
	recipe = value
	label.text = Library.entity_names[recipe.output_type]

	var temp: BlueprintEntity = Library.blueprints[recipe.output_type].instantiate()
	var sprite: Sprite2D = temp.get_node("Sprite2D")

	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.set_atlas(sprite.texture)
	atlas.set_region(sprite.region_rect)

	texture_rect.texture = atlas

	temp.queue_free()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		recipe_activated.emit(recipe)


func _on_mouse_entered() -> void:
	var item_name: String = Library.entity_names[recipe.output_type]
	Events.hovered_over_recipe.emit(item_name, recipe)
	set(CUSTOM_PANEL_PROPERTY, highlight_style)


func _on_mouse_exited() -> void:
	set(CUSTOM_PANEL_PROPERTY, regular_style)
