extends CharacterBody2D

const speed = 550
const jump_power = -2400

const accel = 75
const friction = 45

const gravity = 125

@onready var sprite = $Mask

var initial_scale: Vector2

func _ready() -> void:
	initial_scale = scale

func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = read_input()
	
	if input_dir != Vector2.ZERO:
		acceleration(input_dir)

		var tween = sprite.create_tween()
		tween.tween_property(sprite, "skew", -0.25 * input_dir.x, 0.15)
		
	else:
		add_friction()
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "skew", 0, 0.07)
	move_and_slide()
	jump()
	
func read_input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("left", "right")
	input_dir = input_dir.normalized()
	return input_dir
	
func acceleration(direction):
	velocity = velocity.move_toward(speed * direction, accel)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.5, 0.6), 0.025)
		tween.tween_property(sprite, "scale", Vector2(0.6, 1.5), 0.15)
		tween.tween_property(sprite, "scale", initial_scale, 0.1)
	else:
		velocity.y += gravity
