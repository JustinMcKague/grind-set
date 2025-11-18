extends Area2D

@export var slab_height: float
@export var slab_tex: Texture2D

@onready var sprite = $"../Sprite2D"

func _ready() -> void:
	sprite.texture = slab_tex
	sprite.scale.y = slab_height / sprite.texture.get_height()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("combine_to_slab"):
		var slab_data = SlabResource.new(slab_height, slab_tex)
		body.combine_to_slab(slab_data)
		$"..".queue_free()
	
