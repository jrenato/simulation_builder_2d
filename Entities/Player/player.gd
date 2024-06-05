extends CharacterBody2D

@export var movement_speed: float = 200.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")

	if direction:
		velocity = direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)

	move_and_slide()
