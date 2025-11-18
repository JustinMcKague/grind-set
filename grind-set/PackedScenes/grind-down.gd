extends Sprite2D

signal player_dead

var is_player_dead = false

@onready var mask = $"."
@onready var sprite = $"Rock Base"
@onready var collider = $"../CollisionShape2D"

func grind_edge(surface_direction: Vector2, decay_rate: float) -> void:
	if is_player_dead == false:
		mask.scale -= surface_direction * decay_rate
		sprite.scale += surface_direction * decay_rate
		collider.scale -= surface_direction * decay_rate
		mask.position -= surface_direction * (decay_rate * 2)
		sprite.position += surface_direction * (decay_rate * 100)
		
		if mask.scale.x <= 0 or mask.scale.y <= 0:
			player_dead.emit()
			is_player_dead = true

func _on_character_body_2d_grind(direction: Variant, decay: Variant) -> void:
	grind_edge(direction, decay)
