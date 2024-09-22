extends Area2D

# Variável para armazenar se o jogador está dentro da área de colisão
var can_interact := false

# Função chamada quando um corpo entra na área
func _on_portao_body_entered(body):
	# Verifica se o body é o Player (ajustado para qualquer tipo de Node)
	if body.name == "Player":  # Certifique-se de que o nome do nó do player seja "Player"
		can_interact = true
		print("Player entrou na área")

# Função chamada quando um corpo sai da área
func _on_portao_body_exited(body):
	# Verifica se o body é o Player (ajustado para qualquer tipo de Node)
	if body.name == "Player":
		can_interact = false
		print("Player saiu da área")

# Função que verifica se o jogador pressionou a tecla de interação
func _process(delta):
	if can_interact:
		print("Player pode interagir")
	
	# Alteração para usar "ui_accept" ou uma ação personalizada como "interact"
	if can_interact and Input.is_action_just_pressed("interact"):  # ou "interact" se você criou a ação
		print("Tecla de interação pressionada")
		get_tree().change_scene("res://andar_1.tscn")  # Ajuste do caminho da cena
