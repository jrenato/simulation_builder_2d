extends CenterContainer


## A reference to the inventory that belongs to the 'mouse'. It is a property
## that gives indirect access to DragPreview's blueprint through its getter
## function. No one needs to know that it is stored outside of the GUI class.
var blueprint: BlueprintEntity:
	set = _set_blueprint,
	get = _get_blueprint

@onready var player_inventory: MarginContainer = %InventoryWindow
## We use the reference to the drag preview in the setter and getter functions.
@onready var _drag_preview: Control = %DragPreview


func _ready() -> void:
	# Here, we'll set up any GUI systems that require knowledge of the GUI node.
	# We'll define `InventoryWindow.setup()` in the next lesson.
	player_inventory.setup(self)


## Forwards the `destroy_blueprint()` call to the drag preview.
func destroy_blueprint() -> void:
	_drag_preview.destroy_blueprint()


## Forwards the `update_label()` call to the drag preview.
func update_label() -> void:
	_drag_preview.update_label()


## Setter that forwards setting the blueprint to `DragPreview.blueprint`.
func _set_blueprint(value: BlueprintEntity) -> void:
	if not is_inside_tree():
		await ready
	_drag_preview.blueprint = value


## Getter that returns the DragPreview's blueprint.
func _get_blueprint() -> BlueprintEntity:
	return _drag_preview.blueprint
