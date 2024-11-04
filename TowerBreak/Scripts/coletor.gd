extends CharacterBody2D

enum StateMachine {IDLE, WALK, ATTACK1, ATTACK2, DEATH}

const speed := 80
const dist_follow := 300
const dist_attack := 50

var distance := 0.0
var strong := 10
var health := 3
var animation := ""
var state = StateMachine.IDLE
var direction := 0
var death := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player = owner.get_node("Player")

func _physics_process(delta: float) -> void:
	distance = global_position.distance_to(player.global_position)
	
	match state:
		StateMachine.IDLE:
			_set_animation("idle")
			
			if distance <= dist_follow:
				_enter_state(StateMachine.WALK)


		StateMachine.WALK:
			_set_animation("walk")


		StateMachine.ATTACK1:
			pass

func _enter_state(new_state: StateMachine) -> void:
	if state != new_state:
		state = new_state

func _set_animation(anim: String) -> void:
	if animation != anim:
		animation = animation
		animation_player.play(animation)
