extends CharacterBody2D

@export var animation_tree: AnimationTree
@onready var raycast_vision = $Visao

var state_machine: AnimationNodeStateMachinePlayback
var move_state_machine: AnimationNodeStateMachinePlayback
var attack_state_machine: AnimationNodeStateMachinePlayback

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed: float = 175
var direction: float = 1  # Começa indo para a direita
var counter: int = 0
var delay: float
var flip_delay: float = 1.0  # Delay para flipar
var last_flip_time: float = 0.0  # Controle de tempo para o delay de flip

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	move_state_machine = animation_tree.get("parameters/Movement/playback")
	attack_state_machine = animation_tree.get("parameters/Attack/playback")
	raycast_vision.enabled = true

func _physics_process(delta):
	# Se o RayCast2D detectar o player
	if raycast_vision.is_colliding():
		var target = raycast_vision.get_collider()
		
		if target and target is CharacterBody2D:  # Verifica se o alvo é o player
			move_towards_player(target)
		else:
			move_randomly()  # Se não detectar, anda aleatoriamente
	else:
		move_randomly()  # Se não detectar, anda aleatoriamente

	flip_sprite()  # Chama a função para flipar o sprite

# Função para mover o golem em direção ao player
func move_towards_player(player):
	var direction_to_player = (player.position - position).normalized()
	
	direction = sign(direction_to_player.x)  # Atualiza a direção para o player
	velocity.x = direction * speed  # Move na direção do player
	move_and_slide()

# Função para mover aleatoriamente (mantém a direção)
func move_randomly():
	velocity.x = direction * speed  # Continua na mesma direção
	move_and_slide()

	# Lógica para alternar a direção após um certo tempo
	if position.x < 0 or position.x > 800:  # Muda a condição conforme seu cenário
		direction *= -1  # Inverte a direção

# Função para flipar o sprite com um delay
func flip_sprite():
	
		if direction < 0 and $animacao.flip_h == false:
			$animacao.flip_h = true  # Vira o sprite para a esquerda
		elif direction > 0 and $animacao.flip_h == true:
			$animacao.flip_h = false  # Vira o sprite para a direita
