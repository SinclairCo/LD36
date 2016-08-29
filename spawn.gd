
extends Position2D

var monster_class = preload("res://monster.tscn")
var wait_time = 4.0;
var wait_time_decrease = 0.1;

func _ready():
	get_node("timer").set_wait_time(wait_time * 2)
	pass

func _on_timer_timeout():
	if(wait_time > 2):
		wait_time -= wait_time_decrease
	get_node("timer").set_wait_time((wait_time-wait_time_decrease) + randf() * 2)
	var monster = monster_class.instance()
	monster.set_global_pos(get_global_pos())
	get_tree().get_current_scene().add_child(monster)
