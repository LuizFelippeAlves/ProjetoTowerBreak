extends Node
class_name State

@onready var debug = owner.find_child("debug")
@onready var player = owner.get_parent().find_child("Player")
@onready var animation_player = owner.find_child("AnimationColetor")

func _ready():
	set_physics_process(false)

func enter():
	set_physics_process(true)

func exit():
	set_physics_process(false)

func transition():
	pass

func _physics_process(_delta):
	var Coletor = owner.find_child("Coletor")
	if Coletor:
		transition()
	else:
		set_physics_process(false)  # Desabilita se não encontrar o boss
