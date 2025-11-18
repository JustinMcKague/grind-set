class_name SlabResource
extends Resource

@export var height: float = 16
@export var texture: Texture2D

func _init(initial_height: float = 16, slab_tex: Texture2D = null) -> void:
	height = initial_height
	texture = slab_tex
