
extends Area2D

var timer 
var anim
var resp_time = 15

var picked = false

func _ready():
	timer = get_node("timer")
	anim = get_node("anim")
	timer.set_wait_time(resp_time)
	pass

func do_pickable(picker):
	if( !picked && picker.health < 100): 
		picker.health += 50
		if(picker.health > 100): 
			picker.health = 100
		timer.start()
		picked = true
		anim.play("hide")


func _on_timer_timeout():
	picked = false
	anim.play("show")
	timer.stop()