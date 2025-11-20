extends Camera2D

@export var follow_speed: float = 3.5
@export var cam_offset: Vector2
var target

func _physics_process(delta: float) -> void:
	if target == null:
		target = GameManager.player_ref
	position = position.lerp(target.global_position + cam_offset, delta * follow_speed)
