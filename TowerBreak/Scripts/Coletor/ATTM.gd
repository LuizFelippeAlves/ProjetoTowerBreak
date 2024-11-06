extends State

func enter():
	super.enter()
	animation_player.play("AtaqueMangual")


func transition():
	if owner.direction.length() > 40:
		get_parent().change_state("Andar")
