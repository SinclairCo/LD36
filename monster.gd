
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

var mirrored = false

var dmg_timer = 1
var invincible_time = 0.15
var invincible_timer = 0

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(dmg_timer > 0):
		dmg_timer-=delta
		if(dmg_timer <= 0):
			get_node("dmg").set_text("")
	
	if(health < 0):
		return
	
	if(invincible_timer > 0):
		invincible_timer-=delta
	
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
				
	if(attack_cooldown >= 0):
		attack_cooldown -= delta
		
func mirror_collision(collider):
	collider.set_pos(collider.get_pos()*Vector2(-1,1))
	collider.set_rot(-collider.get_rot())
		
func on_damage(dmg):
	
	if(invincible_timer > 0):
		return
	invincible_timer = invincible_time
	
	health -= dmg
	var old_text = ""
	if(dmg_timer > 0):
		old_text = get_node("dmg").get_text()
	get_node("dmg").set_text(old_text + " " + str(int(dmg)))
	dmg_timer = 1
	print("uffff ", dmg)
	if(health < 0):
		print("Killed")
