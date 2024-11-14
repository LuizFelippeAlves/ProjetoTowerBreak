extends Node2D

@onready var HitDetec: Node2D = $Coletor/AreaHit

func aplicar_dano(dano: int) -> void:
	# Verifica se a área de detecção de hit do inimigo está em contato com a área de dano do player
	for body in HitDetec.get_overlapping_areas():
		if body.is_in_group("DamageDetec"):
			# Obtem o player para aplicar o dano
			var player = body.get_parent()  # Assumindo que "DamageDetec" está como filho do player
			if player and player.has_method("receber_dano"):
				player.receber_dano(dano)
				print("Player atingido! Dano aplicado:", dano)
				return  # Sai da função após aplicar o dano, para evitar múltiplas aplicações
