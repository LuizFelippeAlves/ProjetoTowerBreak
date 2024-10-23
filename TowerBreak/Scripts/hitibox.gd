extends Area2D
class_name Hittbox

@export var flippable_sprite: AnimatedSprite2D

func _ready():
	if flippable_sprite != null:
		for child in get_children():
			flippable_sprite.sprite_flipped.connect(child._on_sprite_flipped)
