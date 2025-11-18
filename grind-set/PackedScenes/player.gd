extends CharacterBody2D

const speed:float = 550
const jump_power = -2400

const accel = 75
const friction = 45

const gravity = 125

@onready var sprite = $Mask

@export var right_particles: GPUParticles2D
@export var left_particles: GPUParticles2D

var initial_scale: Vector2

var on_slab = false

signal grind(direction, decay)

func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = movement()
	
	if input_dir != Vector2.ZERO:
		acceleration(input_dir)
		if is_on_floor():
			grind.emit(Vector2.DOWN, 0.001)
			if input_dir.x > 0:
				left_particles.emitting = true
				right_particles.emitting = false
			else:
				left_particles.emitting = false
				right_particles.emitting = true
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "skew", -0.15 * input_dir.x, 0.15)
		
	else:
		add_friction()
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "skew", 0, 0.07)
	move_and_slide()
	jump()
	if on_slab == true and Input.is_action_just_pressed("combine"):
		# combine logic here
		print("combined with slab")
	if velocity.x == 0:
		right_particles.emitting = false
		left_particles.emitting = false
	
func movement() -> Vector2:
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
		right_particles.emitting = false
		left_particles.emitting = false
		initial_scale = sprite.scale
		velocity.y = jump_power
		var tween = create_tween()
		tween.tween_property(sprite, "scale", sprite.scale * Vector2(1.5, 0.6), 0.025)
		tween.tween_property(sprite, "scale", sprite.scale * Vector2(0.6, 1.5), 0.15)
		tween.tween_property(sprite, "scale", initial_scale, 0.1)
	else:
		velocity.y += gravity

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Slab"):
		on_slab = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Slab"):
		on_slab = false
