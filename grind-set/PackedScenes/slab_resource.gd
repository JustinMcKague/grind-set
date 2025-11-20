class_name SlabResource
extends Resource

@export var height: float = 16
@export var texture: Texture2D
var initial_slab_height: float

func _init(initial_height: float = 16, slab_tex: Texture2D = null, start_height: float = 16) -> void:
	height = initial_height
	texture = slab_tex
	initial_slab_height = start_height
