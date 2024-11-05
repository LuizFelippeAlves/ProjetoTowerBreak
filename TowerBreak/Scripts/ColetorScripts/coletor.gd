extends CharacterBody2D

@onready var player = get_parent().find_child("Player")
@onready var sprite = $AnimatedSprite2D

var direction : Vector2

func _ready():
	set_physics_process(false)

func _process(_delta):
	direction = player.position - position
	
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta):
	velocity = direction.normalized() * 40
	move_and_collide(velocity * delta)
