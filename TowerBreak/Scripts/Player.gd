extends CharacterBody2D

@export var animation_tree : AnimationTree

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
	jump_state_machine = animation_tree.get("parameters/jump/playback")
	attack_state_machine = animation_tree.get("parameters/Attack/playback")


func _physics_process(delta):
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
		state_machine.travel("jump")
		velocity.y = -400

	if Input.is_action_just_pressed("attack_right") and is_on_floor():
		play_attack("1")

func set_motion(value : bool):
	animation_tree.set("parameters/Movement/conditions/can_run", value)
	animation_tree.set("parameters/Movement/conditions/is_stopped", not value)


func flip_sprite():
	if direction < 0:
		$animacao.flip_h = true
	elif direction > 0:
		$animacao.flip_h = false


func play_attack(type : String):
	attack_state_machine.travel("attack_" + type)
	state_machine.travel("Attack")
