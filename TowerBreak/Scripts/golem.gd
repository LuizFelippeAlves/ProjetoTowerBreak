extends CharacterBody2D

@onready var AnimationGolem: AnimationPlayer = $AnimationGolem
@onready var DecParede: RayCast2D = $DecParede

var movimento = Vector2()
var player_in_area = false
var ultima_direcao = 1.0
var player_detectado_uma_vez = false
var distancia_minima_do_player = 30.0  # Distância mínima para manter do jogador

func _ready() -> void:
	add_to_group("Inimigo")
	randomize()
	DecParede.add_exception(get_parent().get_node("Player"))

func _process(delta: float) -> void:
	detectar_parede()
	
	if player_detectado_uma_vez:
		if player_in_area:
			seguir_jogador(delta)
		else:
			seguir_ultima_direcao(delta)

func distancia_ao_jogador() -> float:
	var player = get_parent().get_node_or_null("Player")
	if player:
		return position.distance_to(player.position)
	return INF

func _on_area_detec_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		player_detectado_uma_vez = true
		AnimationGolem.play("idle")  # Usa a animação de idle

func _on_area_detec_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		AnimationGolem.play("idle")  # Continua na animação de idle

func seguir_jogador(delta: float) -> void:
	var player = get_parent().get_node_or_null("Player")
	if player:
		var direction_x = player.position.x - position.x
		ultima_direcao = sign(direction_x)
		position.x += ultima_direcao * delta * 50
		
		if ultima_direcao > 0:
			scale.x = 1
		elif ultima_direcao < 0:
			scale.x = -1

func seguir_ultima_direcao(delta: float) -> void:
	# Continua na última direção até encontrar o jogador novamente
	position.x += ultima_direcao * delta * 50
	AnimationGolem.play("idle")  # Usa a animação de idle para flutuar

func detectar_parede() -> void:
	if DecParede.is_colliding() and not DecParede.get_collider().is_in_group("Player"):  
		ultima_direcao = -ultima_direcao
		scale.x = -scale.x
		print("Parede detectada, virando direção")
