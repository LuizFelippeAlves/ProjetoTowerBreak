extends CharacterBody2D

@onready var AnimationGolem: AnimationPlayer = $AnimationGolem
@onready var DecParede: RayCast2D = $DecParede
@onready var SetProjet: Area2D = $SetProjet
@onready var MarkProjet: Marker2D = $SetProjet/MarkProjet

signal AtualizarVida(VidaAtual)

@export var vida = 200
@export var Derrota = ""

const projetil := preload("res://Util/projetel.tscn")
const pilar := preload("res://Util/pilar.tscn")

var movimento = Vector2()
var player_in_area = false
var player_detectado = false
var ultima_direcao = 1.0
var ataque_em_progresso = false

var contador_pilares = 0
var ataques_realizados = 0
var pilares_bloqueados = false

# Função de espera
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _ready() -> void:
	add_to_group("Inimigo")
	randomize()
	DecParede.add_exception(get_parent().get_node("Player"))

func _process(delta: float) -> void:
	detectar_parede()

	if player_detectado:
		if pilares_bloqueados:
			seguir_player(delta)  # Seguir o jogador se os pilares estiverem bloqueados
		elif player_in_area and not ataque_em_progresso:
			realizar_ataque_com_pilar()  # Ataque com pilar
		elif not player_in_area and not ataque_em_progresso:
			realizar_ataque()  # Realizar ataque de projétil se o jogador saiu da área
	else:
		# Caso o jogador não esteja mais detectado, o inimigo segue o jogador normalmente
		if player_in_area and not ataque_em_progresso:
			seguir_player(delta)

# Detecção do jogador entrando e saindo da área
func _on_area_detec_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		player_detectado = true
		AnimationGolem.play("Idle")
		print("Jogador entrou na área de detecção.")
		ultima_direcao = sign(body.position.x - position.x)
		virar_para_direcao(ultima_direcao)

func _on_area_detec_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		print("Jogador saiu da área de detecção.")
		if not ataque_em_progresso:
			realizar_ataque()  # Atirar projétil quando o jogador sai da área

# Verificação de parede para inversão de direção
func detectar_parede() -> void:
	if DecParede.is_colliding() and not DecParede.get_collider().is_in_group("Player"):
		ultima_direcao = -ultima_direcao
		scale.x = -scale.x
		print("Parede detectada, virando direção.")

# Função de ataque com projétil
func realizar_ataque() -> void:
	ataque_em_progresso = true
	AnimationGolem.play("AtaqueProje")
	print("Iniciando ataque de projétil...")
	await wait(3.1)  # Espera o tempo do ataque de projétil
	ataque_em_progresso = false
	ataques_realizados += 1
	verificar_bloqueio_pilares()

# Função para spawnear o projétil
func spawn_projetil() -> void:
	var novo_projetil = projetil.instantiate()
	if novo_projetil:
		novo_projetil.position = MarkProjet.global_position
		var direcao_projetil = ultima_direcao
		if novo_projetil.has_method("set_direction"):
			novo_projetil.set_direction(direcao_projetil)
		get_parent().add_child(novo_projetil)
		print("Projétil spawnado na posição:", novo_projetil.position)

# Função para realizar ataque com pilar
func realizar_ataque_com_pilar():
	if pilares_bloqueados:
		print("Pilares estão bloqueados, seguindo jogador.")
		return

	ataque_em_progresso = true
	AnimationGolem.play("AtaquePilar")
	print("Iniciando ataque com pilar...")
	await wait(1.2)

	var player = get_parent().get_node_or_null("Player")
	if player and player_in_area:
		var posicao_pilar = Vector2(player.global_position.x, 256)
		spawn_pilar(posicao_pilar)
		await wait(1.1)
		contador_pilares += 1
		print("Pilar invocado. Total de pilares:", contador_pilares)
		if contador_pilares >= 3:
			pilares_bloqueados = true
	else:
		print("Jogador não está mais na área. Ataque cancelado.")
	ataque_em_progresso = false

# Função para spawnar o pilar
func spawn_pilar(pos: Vector2):
	var novo_pilar = pilar.instantiate()
	if novo_pilar:
		novo_pilar.position = pos
		get_parent().add_child(novo_pilar)
		print("Pilar spawnado na posição:", pos)

# Função de ataque curto
func realizar_ataque_curto():
	if ataque_em_progresso:
		return

	var player = get_parent().get_node_or_null("Player")
	if player and position.distance_to(player.position) <= 15:
		ataque_em_progresso = true
		AnimationGolem.play("AtaquePilar")  # Reutilizando animação de ataque do pilar
		print("Iniciando ataque curto!")
		await wait(2.3)
		print("Ataque curto realizado com sucesso.")
		ataques_realizados += 1
		verificar_bloqueio_pilares()
		ataque_em_progresso = false

# Função para seguir o jogador
func seguir_player(delta: float) -> void:
	if ataque_em_progresso:
		return  # Não se move enquanto estiver atacando
	
	var player = get_parent().get_node_or_null("Player")
	if player:
		ultima_direcao = sign(player.position.x - position.x)
		virar_para_direcao(ultima_direcao)
		position.x += ultima_direcao * delta * 50  # Velocidade reduzida ao seguir o jogador

# Função para virar o Golem na direção correta
func virar_para_direcao(direcao: float) -> void:
	scale.x = direcao
	print("Golem virado para direção:", direcao)

# Função para verificar bloqueio de pilares
func verificar_bloqueio_pilares():
	if ataques_realizados >= 13:
		print("Pilares desbloqueados.")
		pilares_bloqueados = false
		contador_pilares = 0
		ataques_realizados = 0

# Função para receber dano
func receber_dano(valor_dano: int) -> void:
	vida -= valor_dano
	emit_signal("AtualizarVida", vida)
	print("Boss recebeu dano:", valor_dano)
	if vida <= 0:
		morrer()

# Função para quando o inimigo morrer
func morrer():
	get_tree().change_scene_to_file(Derrota)
