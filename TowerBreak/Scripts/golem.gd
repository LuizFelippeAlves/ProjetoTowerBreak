extends CharacterBody2D

# Variáveis exportadas para facilitar ajustes no editor
@export var move_speed: float = 200.0
@export var patrol_range: Vector2 = Vector2(200, 100)
@export var attack_range: float = 150.0

# Referências a nós
var player = null
var raycast
var animation_player
var movement_timer
var idle_timer
var arm_cast_timer
var metelancia_timer

# Controle de direção
var direction: Vector2 = Vector2.LEFT
var is_attacking = false

func _ready():
	raycast = $Visao/Mira
	animation_player = $animacao
	movement_timer = $timers/MovementTimer
	idle_timer = $timers/IdleTimer
	arm_cast_timer = $timers/ArmCastTimer
	metelancia_timer = $timers/MetelanciaTimer

	# Acha o jogador na cena
	player = get_tree().get_root().find_node("Player", true, false)

	# Iniciar o movimento aleatório
	_start_random_movement()

func _physics_process(delta: float):
	# Checa se o Golem está em um estado de ataque
	if not is_attacking:
		# Verifica se o jogador está no campo de visão (RayCast)
		raycast.enabled = true
		if raycast.is_colliding() and raycast.get_collider() == player:
			_try_attack()
		else:
			# Movimento aleatório enquanto o jogador não é visto
			_random_movement(delta)

func _random_movement(delta):
	if movement_timer.time_left == 0 and not is_attacking:
		direction.x = randf_range(-1, 1)  # Direção aleatória para esquerda ou direita
		if direction.x != 0:
			animation_player.play("Walk")
		else:
			animation_player.play("Idle")
		velocity = Vector2(direction.x * move_speed, 0)
		move_and_slide()

	if is_on_wall():
		direction = -direction  # Inverte a direção ao colidir com paredes

func _try_attack():
	# Checa qual ataque está disponível (baseado nos timers)
	if arm_cast_timer.time_left == 0:
		_arm_attack()
	elif metelancia_timer.time_left == 0:
		_metelancia_attack()
	else:
		# Se nenhum ataque disponível, continuar patrulhando
		_random_movement(delta)

func _arm_attack() -> void:
	is_attacking = true
	animation_player.play("ArmAttack")
	arm_cast_timer.start()
	await animation_player.animation_finished
	is_attacking = false

func _metelancia_attack() -> void:
	is_attacking = true
	animation_player.play("FloorAttack")
	metelancia_timer.start()
	await animation_player.animation_finished
	is_attacking = false

func _start_random_movement():
	# Configura o movimento aleatório do Golem
	direction.x = randf_range(-1, 1)
	movement_timer.start()
