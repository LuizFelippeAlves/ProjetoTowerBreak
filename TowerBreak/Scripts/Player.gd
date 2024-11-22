extends CharacterBody2D

@export var Derrota = ""
@export var animation_tree : AnimationTree
@export var vida = 150

var state_machine : AnimationNodeStateMachinePlayback
var move_state_machine : AnimationNodeStateMachinePlayback
var jump_state_machine : AnimationNodeStateMachinePlayback
var attack_state_machine : AnimationNodeStateMachinePlayback

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed : float = 175
var direction: float
var counter : int = 0
var delay : float

var on_floor : bool:
	set(value):
		if value == on_floor:
			return
		
		on_floor = value
		if value == true:
			state_machine.travel("Movement")
		else:
			state_machine.travel("jump")

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	move_state_machine = animation_tree.get("parameters/Movement/playback")
	jump_state_machine = animation_tree.get("parameters/Jump/playback")
	attack_state_machine = animation_tree.get("parameters/Attack/playback")

func _physics_process(delta):
	if delta > 0:
		delay -= delta
	direction = Input.get_axis("move_left","move_right")
	velocity.x = direction * speed
	velocity.y += gravity * delta
	move_and_slide()
	
	on_floor = is_on_floor()
	
	if velocity == Vector2.ZERO:
		set_motion(false)
	else:
		set_motion(true)
	
	flip_sprite()
	controls()


func controls():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state_machine.travel("Jump")
		velocity.y = -400
	
	if Input.is_action_just_pressed("dash") and is_on_floor():
		move_state_machine.travel("Dash")
		set_speed(270.0)
		delay = 1.0

	if Input.is_action_just_pressed("attack_right") and delay <= 0 :
		delay = 0.8
		$RESET.start()
		if is_on_floor():
			counter += 1
			attack((counter % 3 == 0))
		if not is_on_floor():
			jump_state_machine.travel("Jump")

func set_motion(value : bool):
	animation_tree.set("parameters/Movement/conditions/can_run", value)
	animation_tree.set("parameters/Movement/conditions/is_stopped", not value)

func set_speed(value: float = 175.0):
	speed = value 

func flip_sprite():
	if direction < 0:
		$AnimatedSprite2D.flipped = true
	elif direction > 0:
		$AnimatedSprite2D.flipped = false


func play_attack(type : String):
	attack_state_machine.travel("Attack_" + type)
	state_machine.travel("Attack")
	set_speed(90)

func attack(is_third):
	if is_third:
		play_attack("2")
		counter = 0
		return
	play_attack("1")

func receber_dano(valor_dano: int) -> void:
	vida -= valor_dano
	print("Player recebeu dano:", valor_dano)
	if vida <= 0:
		morrer()

func morrer():
	get_tree().change_scene_to_file(Derrota)

func _on_reset_timeout() -> void:
	counter = 0
