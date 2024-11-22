extends CharacterBody2D

@onready var AnimationColetor: AnimationPlayer = $AnimationColetor
@onready var DecParede: RayCast2D = $DecParede
@onready var HitDetec: Area2D = $HitDetec

var movimento = Vector2()
var player_in_area = false
var player_in_ataque = false
var is_attacking = false
var ataque_iniciado = false
var ultima_direcao = 1.0
var contador_ataque_mangual = 0
var limite_ataques_mangual = randi_range(4, 7)
var distancia_minima_do_player = 30.0  # Distância mínima para manter do jogador
var player_detectado_uma_vez = false

@export var Derrota = ""
@export var Coletor_Health = 200
@export var Coletor_Damage : float

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _ready() -> void:
	add_to_group("Boss")
	randomize()
	DecParede.add_exception(get_parent().get_node("Player"))

func _process(delta: float) -> void:
	detectar_parede()
	
	if player_detectado_uma_vez and not is_attacking:
		if player_in_ataque:
			if distancia_ao_jogador() > distancia_minima_do_player:
				seguir_jogador(delta)
			else:
				parar_movimento()
		elif player_in_area:
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
		AnimationColetor.play("Andar")

func _on_area_detec_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		if is_attacking:
			print("Esperando fim do ataque para sair da área")
		else:
			AnimationColetor.play("Andar")

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

func _on_area_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking and not ataque_iniciado:
		player_in_ataque = true
		iniciar_ataque()

func _on_area_hit_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_ataque = false

func iniciar_ataque() -> void:
	ataque_iniciado = true
	is_attacking = true
	
	if contador_ataque_mangual < limite_ataques_mangual:
		AnimationColetor.play("AtaqueMangual")
		ataque_mangual()
		contador_ataque_mangual += 1
	else:
		AnimationColetor.play("AtaqueCorpo")
		ataque_corpo()
		contador_ataque_mangual = 0
		limite_ataques_mangual = randi_range(4, 7)

func ataque_corpo() -> void:
	is_attacking = true
	await wait(2.2)
	var player = get_parent().get_node_or_null("Player")
	if player and player_in_ataque == true:
		player.receber_dano(30)  # Aplica o dano ao jogador
	await wait(0.4)
	is_attacking = false
	ataque_iniciado = false
	retomar_movimento()

func ataque_mangual() -> void:
	is_attacking = true
	await wait(1.1)
	var player = get_parent().get_node_or_null("Player")
	if player and player_in_ataque == true:
		player.receber_dano(10)  # Aplica o dano ao jogador
	await wait(0.3)
	is_attacking = false
	ataque_iniciado = false
	retomar_movimento()


func retomar_movimento() -> void:
	if player_in_area and distancia_ao_jogador() > distancia_minima_do_player:
		AnimationColetor.play("Andar")
	else:
		AnimationColetor.play("idle")
	parar_movimento()

func seguir_ultima_direcao(delta: float) -> void:
	# Continua na última direção até encontrar o jogador novamente
	position.x += ultima_direcao * delta * 50
	AnimationColetor.play("Andar")

func detectar_parede() -> void:
	if DecParede.is_colliding() and not DecParede.get_collider().is_in_group("Player"):  
		ultima_direcao = -ultima_direcao
		scale.x = -scale.x
		print("Parede detectada, virando direção")

func parar_movimento() -> void:
	if ultima_direcao != 0 and not is_attacking:
		position.x += ultima_direcao * get_process_delta_time() * 50
	else:
		AnimationColetor.stop()

func receber_dano(valor_dano: int) -> void:
	Coletor_Health -= valor_dano
	print("Boss recebeu dano:", valor_dano)
	if Coletor_Health <= 0:
		morrer()

func morrer():
	get_tree().change_scene_to_file(Derrota)
