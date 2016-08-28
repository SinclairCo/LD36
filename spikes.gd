
extends Area2D

export var need_to_collect = 50
var collected = 0

func _ready():
	pass

func _on_Area2D_body_enter(body):
	print("BODYCHECK")
	if(body.has_method("on_damage")):
		body.on_damage(1000)
		print("whoops!")

