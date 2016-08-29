
extends RigidBody2D

var monster_tag = true #to identify this object

var random_target_timer = 0
var random_target_pos = Vector2(0,0)

const player_class = preload("res://player.gd") # Check if we collide with player
var dead_body = preload("res://dead_monster.tscn") 
var blood = preload("res://effect_bloodhit.tscn") 

var health = 100
var speed = 800
var attack = 10.0
var attack_speed = 2.0

var attack_cooldown = -1;

var look_right = false

var mirrored = false

var dmg_timer = 1
var invincible_time = 0.15
var invincible_timer = 0

var knocked_time = 1.0
var knocked_timer = 0

var dead = false

var speed_limit = 1500

var anim
var player

func _ready():
	set_fixed_process(true)
	anim = get_node("anim")
	player = get_node("player")

func _fixed_process(delta):
	if(dead):
		var corpse = dead_body.instance()
		corpse.set_global_pos(get_global_pos())
		if(!look_right):
			corpse.set_rot(-PI)
		get_tree().get_current_scene().add_child(corpse)
		corpse.get_node("dead_r").set_linear_velocity(get_linear_velocity())
		#corpse.get_node("dead_l").set_linear_velocity(get_linear_velocity()*(1+(randf()-0.5)*0.8))
		queue_free()
		return
	
	if(get_linear_velocity().length() > speed_limit):
		print("Woooaaaaaaaa!")
		set_linear_velocity(get_linear_velocity().normalized()*speed_limit)
	
	if(dmg_timer > 0):
		dmg_timer-=delta
		if(dmg_timer <= 0):
			get_node("dmg").set_text("")
	
	if(health < 0):
		return
	
	if(invincible_timer > 0):
		invincible_timer-=delta
		
	if(knocked_timer > 0):
		knocked_timer-=delta
	
	if( (randi()%700) <= 1 ):
		var sound_id = player.play("reptile_voice")
		player.voice_set_volume_scale_db(sound_id, (randf()-0.5)*0.2)
	
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
	apply_impulse(Vector2(0,0), impulse*(1-min(2*knocked_timer/knocked_time, 1)))
	if(look_right):
		get_node("body").set_scale(Vector2(1,1))
		if(mirrored):
			mirrored = false
			mirror_collision(get_node("legs_collider"))
			mirror_collision(get_node("body_collider"))
	else:
		get_node("body").set_scale(Vector2(-1,1))
		if(!mirrored):
			mirrored = true
			mirror_collision(get_node("legs_collider"))
			mirror_collision(get_node("body_collider"))

	###Process collisions
	var colliding_bodies = get_colliding_bodies();	
	for body in colliding_bodies:
		if body extends player_class:
			if(attack_cooldown < 0):
				#var anim = get_node("Sprites/AnimationPlayer")
				#anim.play("Attack")
				body.on_damage(attack)
				attack_cooldown = 1.0/attack_speed
				anim.play("attack")
				var new_blood = blood.instance()
				new_blood.set_global_pos(get_node("body/blood_bite").get_global_pos())
				get_tree().get_current_scene().add_child(new_blood)
				player.play("bite")
				
	if(attack_cooldown >= 0):
		attack_cooldown -= delta
	
	if(!anim.is_playing()):
		anim.play("run")
		
func mirror_collision(collider):
	collider.set_pos(collider.get_pos()*Vector2(-1,1))
	collider.set_rot(-collider.get_rot())
		
func on_damage(dmg):
	
	if(dmg > 5 && invincible_timer > 0):
		return false
	invincible_timer = invincible_time
	knocked_timer = knocked_time
	health -= dmg
	
	if(look_right):
		apply_impulse(Vector2(0,0), Vector2(-5000, 0))
	else:
		apply_impulse(Vector2(0,0), Vector2(5000, 0))
	
	#var old_text = ""
	#if(dmg_timer > 0):
	#	old_text = get_node("dmg").get_text()
	get_node("dmg").set_text(str(int(dmg)))
	dmg_timer = 1
	#print("uffff ", dmg)
	if(health < 0 && !dead):
		dead = true
	return true
