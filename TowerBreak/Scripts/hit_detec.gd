extends Area2D

var dano = 10

func _ready() -> void:
	pass 

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
	# Aplica dano ao jogador
		body.receber_dano(dano)
		print("Boss atingido! Dano aplicado:", dano)
