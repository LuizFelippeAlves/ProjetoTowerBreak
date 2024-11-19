extends  Area2D

const  speed := 100

var velocity := Vector2.ZERO
var direction := 1

func  _ready() -> void:
	pass

func set_direction(dir):
	direction = dir
	if direction == 1:
		$Projetil.flip_h = false
	else:
		$Projetil.flip_h = true

func _physics_process(delta: float) -> void:
	velocity.x = speed * delta * direction
	translate(velocity)
