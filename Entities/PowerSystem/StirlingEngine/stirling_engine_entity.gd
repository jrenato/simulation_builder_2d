class_name StirlingEngineEntity extends Entity

## The following two constants are respectively the amount of time the tween animation takes
## to ramp up to full speed and to shutdown.
## We will use that to speed up or slow down the animation player
const BOOTUP_TIME: float = 6.0
const SHUTDOWN_TIME: float = 3.0

@onready var piston_shaft: Sprite2D = %PistonShaft
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var power_source: PowerSource = %PowerSource


func _ready() -> void:
	# Play the animation, which loops.
	animation_player.play("work")

	var tween: Tween = create_tween()

	# We use a tween to control the animation player's `playback_speed`.
	# It goes up, making it feel like the engine is slowly starting up until it reaches its maximum speed.
	tween.tween_property(animation_player, "speed_scale", 1.0, BOOTUP_TIME)
	tween.set_parallel()
	# We also animate the color of the `shaft` to enhance the animation, going from white to green.
	tween.tween_property(piston_shaft, "modulate", Color(0.5, 1.0, 0.5), BOOTUP_TIME)
	tween.set_parallel()
	tween.tween_property(power_source, "efficiency", 1.0, BOOTUP_TIME)
