extends Entity

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var gui_component: GUIComponent = %GUIComponent


func _ready() -> void:
	gui_component.gui_opened.connect(_on_gui_component_gui_opened)
	gui_component.gui_closed.connect(_on_gui_component_gui_closed)


func _on_gui_component_gui_opened() -> void:
	animation_player.play("open")


func _on_gui_component_gui_closed() -> void:
	animation_player.play("close")
