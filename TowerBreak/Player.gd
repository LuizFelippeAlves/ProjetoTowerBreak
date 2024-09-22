extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping := false

@onready var animation := $animacao as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Adiciona gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Lida com pulo usando a tecla 'W'
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		print("Player pulou")
	elif is_on_floor():
		is_jumping = false

	# Obtém direção para movimento (A para esquerda, D para direita)
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if !is_jumping and velocity.x != 0:
			animation.play("Running")
			print("Player andando")
	elif is_jumping:
		animation.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("Idle")

	move_and_slide()
