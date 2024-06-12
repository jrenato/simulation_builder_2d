class_name Player extends CharacterBody2D

@export var movement_speed: float = 200.0

@onready var pickup_radius: Area2D = %PickupRadiusArea2D


func _ready() -> void:
	pickup_radius.area_entered.connect(_on_pickup_radius_area_area_entered)


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")

	if direction:
		velocity = direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)

	move_and_slide()


func _on_pickup_radius_area_area_entered(area: Area2D) -> void:
	# Get the area's parent - that's the actual blueprint entity class.
	var parent: GroundEntity = area.get_parent()
	if parent:
		# Triggers an event on our event bus pattern about an item getting
		# picked up. This signal can be connected to by the GUI.
		Events.entered_pickup_area.emit(parent, self)
