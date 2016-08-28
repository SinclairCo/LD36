
extends Area2D

export var need_to_collect = 50
var collected = 0

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	var bodies = get_overlapping_bodies();
	for body in bodies:
		var groups = body.get_groups()
		if(groups.has("corpse_score")):
			body.get_parent().queue_free()
			print("Wooohooo!")
			collected += 1
			if(get_tree().get_current_scene().has_node("player")):
				var progress = (collected * 1.0 / need_to_collect) * 100
				get_tree().get_current_scene().get_node("player/ui/food").set_value(progress)
				if(progress >= 100):
					print("You won!")
					get_tree().change_scene("res://youwin.tscn")
		elif(body.has_method("on_damage")):
			body.on_damage(1)
			#print("whoops!")
