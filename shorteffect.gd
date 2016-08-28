
extends Particles2D

var wait_time = 5.0;

func _ready():
	get_node("Timer").set_wait_time(wait_time)
	pass

func _on_Timer_timeout():
	queue_free()

