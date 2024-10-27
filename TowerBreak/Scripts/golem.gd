extends CharacterBody2D

@export var animation_tree : AnimationTree
@export var raycast : RayCast2D
@export var movement_speed : float = 100.0

var state_machine : AnimationNodeStateMachinePlayback
var move_state_machine : AnimationNodeStateMachinePlayback
var attack_state_machine : AnimationNodeStateMachinePlayback

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float
var player : Node2D = null
var delay : float
var counter : int = 0

# Timers para controlar os ataques e movimentos
@export var movement_timer : Timer
@export var idle_timer : Timer
@export var arm_cast_timer : Timer
@export var floor_attack_timer : Timer

var on_floor : bool:
	set(value):
		if value == on_floor:
			return
		
		on_floor = value
		if value == true:
			state_machine.travel("Movement")
		else:
			state_machine.travel("Idle")

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	move_state_machine = animation_tree.get("parameters/Movement/playback")
	attack_state_machine = animation_tree.get("parameters/Attack/playback")
	
	raycast.enabled = true  # Ativa o raycast para procurar o jogador
	random_movement()  # Inicia com movimento aleatório

func _physics_process(delta):
	if delta > 0:
		delay -= delta

	# Verifica se o RayCast detecta o jogador
	if raycast.is_colliding():
		player = raycast.get_collider()
		if player and player.is_in_group("player"):
			chase_player(delta)
	else:
		random_movement()  # Se não detectar o jogador, se move aleatoriamente
	
	on_floor = is_on_floor()

	if velocity == Vector2.ZERO:
		set_motion(false)
	else:
		set_motion(true)

	move_and_slide()

# Persegue o jogador
func chase_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * movement_speed
	
	# Alterna animação para "Movement"
	move_state_machine.travel("Movement")

	# Verifica se há ataques disponíveis
	if floor_attack_timer.time_left == 0:
		attack("Attack_floor_attack")
	elif arm_cast_timer.time_left == 0:
		attack("Attack_hand_attack")

# Executa um ataque
func attack(attack_name: String):
	attack_state_machine.travel(attack_name)
	
	# Inicia o cooldown do ataque
	if attack_name == "Attack_floor_attack":
		floor_attack_timer.start()
	elif attack_name == "Attack_hand_attack":
		arm_cast_timer.start()

# Movimento aleatório quando não vê o jogador
func random_movement():
	if movement_timer.time_left == 0:
		var random_direction = Vector2(randf() * 2 - 1, 0).normalized()
		velocity.x = random_direction.x * movement_speed
		
		# Alterna animação para "Movement"
		move_state_machine.travel("Movement")
		movement_timer.start()
	else:
		# Alterna para animação Idle
		state_machine.travel("Idle")

# Função para controlar as condições de movimento
func set_motion(value : bool):
	animation_tree.set("parameters/Movement/conditions/can_run", value)
	animation_tree.set("parameters/Movement/conditions/is_stopped", not value)
