extends CharacterBody2D

@export var animation_tree : AnimationTree
@onready var raycast_vision = $Visao

var state_machine : AnimationNodeStateMachinePlayback
var move_state_machine : AnimationNodeStateMachinePlayback
var attack_state_machine : AnimationNodeStateMachinePlayback

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed : float = 175
var direction: float
var counter : int = 0
var delay : float

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	move_state_machine = animation_tree.get("parameters/Movement/playback")
	attack_state_machine = animation_tree.get("parameters/Attack/playback")
	raycast_vision.enabled = true 


func flip_sprite():
	if direction < 0:
		$animacao.flip_h = true
	elif direction > 0:
		$animacao.flip_h = false
