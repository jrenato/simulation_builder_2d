extends CenterContainer


## A reference to the inventory that belongs to the 'mouse'. It is a property
## that gives indirect access to DragPreview's blueprint through its getter
## function. No one needs to know that it is stored outside of the GUI class.
var blueprint: BlueprintEntity:
	set = _set_blueprint,
	get = _get_blueprint

## If `true`, it means the mouse is over the `GUI` at the moment.
var mouse_in_gui: bool = false

@onready var player_inventory: MarginContainer = %InventoryWindow
## We use the reference to the drag preview in the setter and getter functions.
@onready var is_open: bool = player_inventory.visible
@onready var _drag_preview: Control = %DragPreview
@onready var _inventory_container: HBoxContainer = %InventoryContainer


func _ready() -> void:
	# Here, we'll set up any GUI systems that require knowledge of the GUI node.
	# We'll define `InventoryWindow.setup()` in the next lesson.
	player_inventory.setup(self)


func _process(delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	# If the mouse is inside the GUI rect and the GUI is open, set it true.
	mouse_in_gui = is_open and _inventory_container.get_rect().has_point(mouse_position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if is_open:
			_close_inventories()
		else:
			_open_inventories()


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


## Shows the inventory window, crafting window
func _open_inventories() -> void:
	is_open = true
	player_inventory.visible = true


## Hides the inventory window, crafting window, and any currently open machine GUI
func _close_inventories() -> void:
	is_open = false
	player_inventory.visible = false
