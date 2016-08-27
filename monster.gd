
extends RigidBody2D

var monster_tag = true #to identify this object

var random_target_timer = 0
var random_target_pos = Vector2(0,0)

const player_class = preload("res://player.gd") # Check if we collide with player

var health = 100
var speed = 800
var attack = 10.0
var attack_speed = 2.0

var attack_cooldown = -1;

var look_right = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(health < 0):
		return
	
	var target_pos
	if(get_tree().get_current_scene().has_node("player")):
		var player = get_tree().get_current_scene().get_node("player")
		target_pos = player.get_global_pos()
	else:
		random_target_timer-=delta
		if(random_target_timer <= 0):
			random_target_pos.x = get_global_pos().x+(randf()-0.5)*speed
			random_target_pos.y = get_global_pos().y+(randf()-0.5)*speed
			random_target_timer = 2
			target_pos = random_target_pos

	var direction = (target_pos - get_global_pos()).normalized()
	
	var is_moving = direction.x != 0
	if(is_moving):
		look_right = direction.x > 0
	
	var impulse = (Vector2(direction.x*speed, 0) - Vector2(get_linear_velocity().x,0))*get_mass()
	#print("m ",get_linear_velocity().x, impulse)
	apply_impulse(Vector2(0,0), impulse)
	if(look_right):
		get_node("body").set_scale(Vector2(1,1))
	else:
		get_node("body").set_scale(Vector2(-1,1))

	var colliding_bodies = get_colliding_bodies();
	
	for body in colliding_bodies:
		if body extends player_class:
			if(attack_cooldown < 0):
				#var anim = get_node("Sprites/AnimationPlayer")
				#anim.play("Attack")
				body.on_damage(attack)
				attack_cooldown = 1.0/attack_speed
				
	if(attack_cooldown >= 0):
		attack_cooldown -= delta
		
func on_damage(dmg):
	health -= dmg
	if(health < 0):
		print("Killed")
