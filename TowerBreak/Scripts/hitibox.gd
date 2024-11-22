extends Area2D
class_name Hittbox

@export var flippable_sprite: AnimatedSprite2D
var dano = 10

func _ready():
	if flippable_sprite != null:
		for child in get_children():
			flippable_sprite.sprite_flipped.connect(child._on_sprite_flipped)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Boss"):
	# Aplica dano ao jogador
		body.receber_dano(dano)
		print("Boss atingido! Dano aplicado:", dano)
