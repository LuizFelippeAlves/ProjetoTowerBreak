extends CharacterBody2D

@onready var AnimationGolem: AnimationPlayer = $AnimationGolem
@onready var DecParede: RayCast2D = $DecParede
@onready var SetProjet: Area2D = $SetProjet
@onready var MarkProjet: Marker2D = $SetProjet/MarkProjet

const projetil := preload("res://Util/projetel.tscn")  # Certifique-se de que o caminho está correto

var movimento = Vector2()
var player_in_area = false
var player_detectado = false
var ultima_direcao = 1.0
var ataque_em_progresso = false

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
		if player_in_area:
			seguir_player(delta)
		elif not ataque_em_progresso:
			realizar_ataque()

func _on_area_detec_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		player_detectado = true
		AnimationGolem.play("Idle")
		print("Jogador entrou na área de detecção.")

func _on_area_detec_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		print("Jogador saiu da área de detecção.")

func seguir_player(delta: float) -> void:
	var player = get_parent().get_node_or_null("Player")
	if player:
		ultima_direcao = sign(player.position.x - position.x)
		scale.x = ultima_direcao
		position.x += ultima_direcao * delta * 50
		AnimationGolem.play("Idle")

func detectar_parede() -> void:
	if DecParede.is_colliding() and not DecParede.get_collider().is_in_group("Player"):
		ultima_direcao = -ultima_direcao
		scale.x = -scale.x
		print("Parede detectada, virando direção.")

func realizar_ataque() -> void:
	# Garante que nenhum outro ataque ocorra
	ataque_em_progresso = true

	# Inicia a animação de ataque
	AnimationGolem.play("AtaqueProje")
	print("Iniciando ataque...")

	# Aguarda o tempo total da animação antes de liberar para o próximo ataque
	await wait(3.0)

	# Certifique-se de que `spawn_projetil` foi chamado durante a animação
	if not ataque_em_progresso:
		print("Aviso: O ataque foi liberado antes do tempo.")

	# Libera o próximo ataque
	ataque_em_progresso = false

func spawn_projetil() -> void:
	print("Tentando spawnar projétil...")

	# Certifica-se de que o projétil será criado
	var novo_projetil = projetil.instantiate()
	if not novo_projetil:
		print("Erro ao instanciar o projétil.")
		return

	# Configura posição e direção do projétil
	novo_projetil.position = MarkProjet.global_position
	var direcao_projetil = ultima_direcao
	if novo_projetil.has_method("set_direction"):
		novo_projetil.set_direction(direcao_projetil)

	get_parent().add_child(novo_projetil)

	print("Projétil spawnado com sucesso na posição:", novo_projetil.position)

	# Confirma que o projétil foi spawnado corretamente
	ataque_em_progresso = true
