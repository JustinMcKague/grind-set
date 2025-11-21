extends CharacterBody2D

const speed:float = 550
const jump_power = -2400

const accel = 75
const friction = 45

const gravity = 125

@export var initial_height: float
@export var decay_rate: float
@export var min_height: float = 0.1

var current_height: float
var current_slabs: Array = []
var is_sliding = false
var initial_coll_height: float

@onready var collision = $CollisionShape2D
@onready var sprite = $"Rock Base"
@onready var slab_parent = $"Rock Base/SlabParent"
@onready var raycast = $"Rock Base/RayCast2D"

@export var right_particles: GPUParticles2D
@export var left_particles: GPUParticles2D

var player_height

var slab_prefab = preload("res://PackedScenes/slab.tscn")

var initial_scale: Vector2

var on_slab = false
@export var can_jump:bool = false

var current_offset

@onready var coyote_timer = $"Coyote Time"
@onready var buffer = $"Jump Buffer"
@onready var jump_cd = $"Jump CD"

var max_jumps = 1
var current_jumps = 0

func _ready() -> void:
	GameManager.player_ref = self
	current_height = initial_height
	initial_coll_height = collision.shape.size.y
	update_player_height()

func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = movement()
	if not can_jump:
		coyote_timer.stop()
	if Input.is_action_just_pressed("jump") and not is_on_floor() and buffer.is_stopped():
		buffer.start()
	if input_dir != Vector2.ZERO:
		acceleration(input_dir)
		if is_on_floor():
			manage_particles(input_dir)
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "skew", -0.15 * input_dir.x, 0.15)
		is_sliding = true
	else:
		add_friction()
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "skew", 0, 0.07)
		is_sliding = false
	
	if can_jump and not is_on_floor() and coyote_timer.is_stopped():
		coyote_timer.start()
	handle_jump()
	grind(delta)
	update_player_height()
	move_and_slide() # MAKE SURE THIS IS BELOW THE JUMP FUNCTION
	if is_on_floor():
		coyote_timer.stop()
		can_jump = true
		current_jumps = 0
	if velocity.x == 0:
		right_particles.emitting = false
		left_particles.emitting = false
	if on_slab == true and Input.is_action_just_pressed("combine"):
		# combine logic here
		print("combined with slab")
	
func grind(delta):
	if is_sliding:
		var amount_to_grind = decay_rate * delta
		
		for slab in current_slabs:
			if amount_to_grind <= 0:
				break
			if slab.height > amount_to_grind:
				slab.height -= amount_to_grind
				amount_to_grind = 0
			else:
				amount_to_grind -= slab.height
				slab.height = 0
		current_slabs = current_slabs.filter(func(slab): return slab.height > 0)
		
		if amount_to_grind > 0:
			current_height = max(min_height, current_height - amount_to_grind)
			
		if current_height <= min_height and current_slabs.is_empty():
			game_over()
	
func manage_particles(input_dir):
	if input_dir.x > 0:
		left_particles.emitting = true
		right_particles.emitting = false
	else:
		left_particles.emitting = false
		right_particles.emitting = true
	if not is_on_floor():
		left_particles.emitting = false
		right_particles.emitting = false
	
func update_player_height():
	for child in slab_parent.get_children():
		child.queue_free()
		
	sprite.global_scale.y = current_height / initial_height
	
	# attach new slab sprites to bottom of player
	current_offset = current_height
	
	for i in range(current_slabs.size() -1, -1, -1):
		var slab = current_slabs[i]
		var slab_sprite = Sprite2D.new()
		slab_sprite.texture = slab.texture
		slab_sprite.scale.y = slab.height / slab_sprite.texture.get_height() * 2
		slab_sprite.global_scale.x = sprite.global_scale.x * 2
		current_offset += slab.height
		slab_sprite.position.y = current_offset - ((slab.height - slab.initial_slab_height) / 2)
		slab_parent.add_child(slab_sprite)
	
	var total_height = current_height
	for slab in current_slabs:
		total_height += slab.height
		
	player_height = total_height
	var new_coll_height = initial_coll_height * (total_height / initial_height)
	collision.shape.size.y = new_coll_height
	var offset = (initial_coll_height - new_coll_height) / 2
	collision.position.y = offset
	$Detection/CollisionShape2D.shape.size.y = new_coll_height
	$Detection/CollisionShape2D.position.y = offset
	sprite.position.y = offset
	
func combine_to_slab(slab_data):
	current_slabs.append(slab_data)

func movement() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("left", "right")
	input_dir = input_dir.normalized()
	return input_dir
	
func acceleration(direction):
	velocity = velocity.move_toward(speed * direction, accel)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func handle_jump():
	if jump_cd.time_left > 0:
		pass
	if Input.is_action_just_pressed("jump") and can_jump and current_jumps < max_jumps:
		jump_cd.start()
		can_jump = false
		jump()
	else:
		velocity.y += gravity
		
func jump():
	can_jump = false
	current_jumps += 1
	coyote_timer.stop()
	right_particles.emitting = false
	left_particles.emitting = false
	initial_scale = sprite.scale
	velocity.y = jump_power
	var tween = create_tween()
	tween.tween_property(sprite, "scale", sprite.scale * Vector2(1.5, 0.6), 0.025)
	tween.tween_property(sprite, "scale", sprite.scale * Vector2(0.6, 1.5), 0.15)
	tween.tween_property(sprite, "scale", initial_scale, 0.1)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Slab"):
		on_slab = true
	if Input.is_action_just_pressed("combine"):
		area.get_tree().queue_free()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Slab"):
		on_slab = false

func game_over():
	print("You lose.")

func _on_coyote_time_timeout() -> void:
	can_jump = false

func _on_jump_buffer_timeout() -> void:
	if is_on_floor():
		jump()
		buffer.stop()
	else:
		buffer.stop()
