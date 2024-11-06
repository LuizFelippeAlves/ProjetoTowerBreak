extends State

@onready var collision = %Area

func enter():
	super.enter()
	owner.set_physics_process(true)
	animation_player.play("Andar")

func exit():
	super.exit()
	owner.set_physics_process(false)

func transition():
	if owner.get_direction().length() < 40:
		get_parent().change_state("AtaqueMangual")
