
extends Particles2D

# member variables here, example:
# var a=2
# var b="textvar"

var wait_time = 5.0;
var wait_time_decrease = 0.1;

func _ready():
	print("ready")
	get_node("Timer").set_wait_time(wait_time)
	pass

func _on_Timer_timeout():
	print("timeout")
	queue_free()

