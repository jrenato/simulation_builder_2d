extends PanelContainer

var recipe: Recipe

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## Sets up the sprite and label with the provided recipe data.
func setup(_recipe: Recipe) -> void:
	recipe = _recipe
	label.text = Library.entity_names[recipe.output_type]

	var temp: BlueprintEntity = Library.blueprints[recipe.output_type].instantiate()
	var sprite: Sprite2D = temp.get_node("Sprite2D")

	texture_rect.texture.atlas = sprite.texture
	texture_rect.texture.region = sprite.region_rect

	temp.queue_free()


func _on_mouse_entered() -> void:
	var item_name: String = Library.entity_names[recipe.output_type]
	Events.hovered_over_recipe.emit(item_name, recipe)


func _on_mouse_exited() -> void:
	pass # Replace with function body.
