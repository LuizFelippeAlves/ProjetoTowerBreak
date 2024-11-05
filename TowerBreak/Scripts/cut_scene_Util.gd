extends Node2D

@export var animation_play : AnimationPlayer
@export var camera : Camera2D

var Shake_Strength: float = 0.0
var DECAY_RATE: float = 5.0

func apply_shake():
	Shake_Strength = 10

func _process(delta):
	Shake_Strength = lerp(Shake_Strength, 0.0, DECAY_RATE * delta)
	camera.offset = get_random_offset()

func get_random_offset() -> Vector2:
	return Vector2(
		randf_range(-Shake_Strength,Shake_Strength),
		randf_range(-Shake_Strength,Shake_Strength)
	)
