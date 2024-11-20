extends CharacterBody2D

@onready var AnimationGolem: AnimationPlayer = $AnimationGolem
@onready var DecParede: RayCast2D = $DecParede
@onready var SetProjet: Area2D = $SetProjet
@onready var MarkProjet: Marker2D = $SetProjet/MarkProjet

const projetil := preload("res://Util/projetel.tscn")  # Certifique-se de que o caminho está correto

var movimento = Vector2()
var player_in_area = false
var player_detectado = false  # Garante que o inimigo só ataque após detectar o jogador uma vez
var ultima_direcao = 1.0
var ataque_em_progresso = false  # Controla se um ataque está em andamento
var tempo_entre_ataques = 2.0  # Tempo de espera entre ataques
var temporizador_ataque = 0.0

func _ready() -> void:
	add_to_group("Inimigo")
	randomize()
	DecParede.add_exception(get_parent().get_node("Player"))

func _process(delta: float) -> void:
	detectar_parede()

	if player_detectado:
		if player_in_area:
			seguir_player(delta)
		else:
			temporizador_ataque -= delta
			if temporizador_ataque <= 0 and not ataque_em_progresso:
				realizar_ataque()

func distancia_ao_jogador() -> float:
	var player = get_parent().get_node_or_null("Player")
	if player:
		return position.distance_to(player.position)
	return INF

func _on_area_detec_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		player_detectado = true  # Marca que o jogador foi detectado pela primeira vez
		AnimationGolem.play("Idle")  # Usa a animação de idle
		print("Jogador entrou na área de detecção.")

func _on_area_detec_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		temporizador_ataque = tempo_entre_ataques  # Reinicia o temporizador para ataques
		print("Jogador saiu da área de detecção.")

func seguir_player(delta: float) -> void:
	var player = get_parent().get_node_or_null("Player")
	if player:
		ultima_direcao = sign(player.position.x - position.x)
		scale.x = ultima_direcao  # Atualiza a orientação visual do inimigo
		position.x += ultima_direcao * delta * 50
		AnimationGolem.play("Idle")  # Usa a animação de idle enquanto persegue

func detectar_parede() -> void:
	if DecParede.is_colliding() and not DecParede.get_collider().is_in_group("Player"):  
		ultima_direcao = -ultima_direcao
		scale.x = -scale.x
		print("Parede detectada, virando direção.")

func realizar_ataque() -> void:
	ataque_em_progresso = true
	temporizador_ataque = tempo_entre_ataques  # Reinicia o temporizador
	AnimationGolem.play("AtaqueProje")  # Inicia a animação de ataque

# Chamado pela animação para spawnar o projétil no momento certo
func spawn_projetil() -> void:
	var player = get_parent().get_node_or_null("Player")
	if not player:
		print("Jogador não encontrado, abortando projétil.")
		return

	var novo_projetil = projetil.instantiate()
	if not novo_projetil:
		print("Erro ao instanciar o projétil.")
		return

	novo_projetil.position = MarkProjet.global_position
	var direcao_projetil = sign(player.position.x - position.x)
	novo_projetil.set_direction(direcao_projetil)  # Certifique-se de que este método existe no script do projétil
	get_parent().add_child(novo_projetil)

# Finaliza o ataque e permite outro
func finalizar_ataque() -> void:
	ataque_em_progresso = false
