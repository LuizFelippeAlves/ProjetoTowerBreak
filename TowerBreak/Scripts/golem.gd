extends CharacterBody2D

@export var animation_tree : AnimationTree
@export var raycast : RayCast2D
@export var movement_speed : float = 100.0  # Verifique se isso está atribuído corretamente no editor

var state_machine : AnimationNodeStateMachinePlayback
var move_state_machine : AnimationNodeStateMachinePlayback
var attack_state_machine : AnimationNodeStateMachinePlayback

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float
var player : Node2D = null
var delay : float = 0
var counter : int = 0
var attack_name = ""

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
			if state_machine:
				state_machine.travel("Movement")
		else:
			if state_machine:
				state_machine.travel("Idle")

func _ready():
	if animation_tree:
		state_machine = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
		move_state_machine = animation_tree.get("parameters/Movement/playback") as AnimationNodeStateMachinePlayback
		attack_state_machine = animation_tree.get("parameters/Attack/playback") as AnimationNodeStateMachinePlayback

	if raycast:
		raycast.enabled = true
	
	# Iniciar o movimento aleatório
	print("Iniciando movimento aleatório.")
	random_movement()

func _physics_process(delta):
	if delta > 0:
		delay -= delta

	# Detecção do jogador através do RayCast2D
	if raycast and raycast.is_colliding():
		player = raycast.get_collider()
		if player and player.is_in_group("player"):
			chase_player(delta)
	else:
		random_movement()

	on_floor = is_on_floor()



	move_and_slide()

func chase_player(delta):
	print("Chasing Player")
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * movement_speed
	
	if move_state_machine:
		move_state_machine.travel("Movement")

	if floor_attack_timer and floor_attack_timer.time_left == 0:
		attack("Attack_floor_attack")
		attack_name = "Attack_floor_attack"
	elif arm_cast_timer and arm_cast_timer.time_left == 0:
		attack("Attack_hand_attack")
		attack_name = "Attack_hand_attack"

func attack(attack_name: String):
	print("Attacking with:", attack_name)
	if attack_state_machine:
		attack_state_machine.travel(attack_name)
	
	if attack_name == "Attack_floor_attack" and floor_attack_timer:
		floor_attack_timer.start()
		attack_name = ""
	elif attack_name == "Attack_hand_attack" and arm_cast_timer:
		arm_cast_timer.start()
		attack_name = ""

func random_movement():
	if movement_timer and movement_timer.time_left == 0:
		print("Moving Randomly")
		var random_direction = Vector2(randf() * 2 - 1, 0).normalized()
		velocity.x = random_direction.x * movement_speed
		print("Random Velocity X:", velocity.x)
		if move_state_machine:
			move_state_machine.travel("Movement")
		movement_timer.start()
	else:
		if state_machine:
			state_machine.travel("Idle")

func set_motion(value : bool):
	if animation_tree:
		animation_tree.set("parameters/Movement/conditions/can_run", value)
		animation_tree.set("parameters/Movement/conditions/is_stopped", not value)
