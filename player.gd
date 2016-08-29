
extends RigidBody2D

var run_speed = 700
var acceleration = 5000;
var jump_imp = 2750;

var speed_limit = 1500

var next_jump_delay = 0.080;
var current_jump_delay = 0;

var mace_base_last_pos = Vector2(0,0)

var max_arm_length = 0

var look_right = false

var health = 100

var almost_dead = false
var dead = false
var death_time = 2

var pick_dist = 400

var anim
var player

var dragging_thing = null

func _ready():
	set_fixed_process(true)
	max_arm_length = (get_node("max_arm_length").get_global_pos() - get_node("body/arms/shoulder").get_global_pos()).length()
	anim = get_node("body/anim")
	player = get_node("player")
	randomize()
	#set_process_input(true)
	pass
	
func _fixed_process(delta):
	
	if(get_linear_velocity().length() > speed_limit):
		print("Weeeeeeeee!")
		set_linear_velocity(get_linear_velocity().normalized()*speed_limit)
	
	get_node("ui/health").set_value(health)
	
	if(dead):
		death_time -= delta
		if(death_time < 0):
			get_tree().change_scene("res://mainmenu.tscn")
		return
	
	#########################################
	####MOVE AND JUMP########################
	#########################################
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var direction = Vector2((right - left), 0).normalized()
	
	var is_moving = direction.x != 0
	if(is_moving):
		look_right = direction.x > 0
		if(!anim.is_playing() || anim.get_current_animation() != "run"):
			anim.play("run")
	
	if(!is_moving):
		if(!anim.is_playing() || anim.get_current_animation() != "stand"):
			anim.play("stand")
		if(abs(get_linear_velocity().x) > 0.1):
			apply_impulse(Vector2(0,0), Vector2(-get_linear_velocity().x*get_mass(),0))
			#print("s ",get_linear_velocity().x)
	elif( abs(get_linear_velocity().x) < run_speed ):
		var impulse = (direction*run_speed - Vector2(get_linear_velocity().x,0))*get_mass()
		#print("m ",get_linear_velocity().x, impulse)
		apply_impulse(Vector2(0,0), impulse)
		if(look_right):
			get_node("body").set_scale(Vector2(-1,1))
		else:
			get_node("body").set_scale(Vector2(1,1))
	else:
		#print("ml ", get_linear_velocity().x)
		pass

	var jump = Input.is_action_pressed("jump");
	var space_state = get_world_2d().get_direct_space_state()
	var floor_cast = space_state.intersect_ray(get_global_pos(), get_node("bottom").get_global_pos(), [self], 3)
	var has_floor = (!floor_cast.empty()) && get_colliding_bodies().size() > 0
	if(jump && has_floor && current_jump_delay <= 0):
		current_jump_delay = next_jump_delay
		apply_impulse(Vector2(0,0), Vector2(0,-jump_imp)) 
	elif(current_jump_delay > 0):
		current_jump_delay -= delta
		
	#########################################
	####MOVE ARM#############################
	#########################################
	
	#get camera transformation to convert screen coordinates to world coordinates
	var transform = get_viewport().get_canvas_transform()
	#convert mouse pos to world pos
	var global_aim_pos = transform.affine_inverse() * get_viewport().get_mouse_pos()
	
	#limit mace position with some distance around shoulder
	var arms_base_pos = get_node("body/arms/shoulder").get_global_pos()
	var direction_from_shoulder = global_aim_pos - arms_base_pos
	var trimmed_global_aim_pos = global_aim_pos
	if(direction_from_shoulder.length() > max_arm_length):
		direction_from_shoulder = direction_from_shoulder.normalized()*max_arm_length
		trimmed_global_aim_pos = arms_base_pos + direction_from_shoulder
	
	var mace_base = get_node("mace_joint_base")
	#change position with velocity to have accurate joint simulation
	mace_base.set_linear_velocity((trimmed_global_aim_pos - mace_base.get_global_pos())/delta)
	
	#rotate arms... manually
	var sin_a = direction_from_shoulder.length()/2/(max_arm_length/2)
	var asin_a = PI/2
	if(sin_a <= 0.999):
		 asin_a = asin(sin_a)
	var shoulder_angle = PI/2 - asin_a
	
	#print(shoulder_angle, " " , direction_from_shoulder.length()/2, " " , max_arm_length/2, " ", direction_from_shoulder.length()/2/(max_arm_length/2))
	var arm_direction
	if(look_right):
		arm_direction = -direction_from_shoulder.angle() + PI/2;
	else:
		arm_direction = direction_from_shoulder.angle() + PI/2;
	get_node("body/arms/shoulder").set_rot(arm_direction+shoulder_angle)
	get_node("body/arms/shoulder/hand_arm").set_rot(PI + (PI/2 - shoulder_angle)*2)

	if(Input.is_action_pressed("pick")):
		if( (dragging_thing == null || !dragging_thing.get_ref() ) && (global_aim_pos - arms_base_pos).length() < pick_dist):
			var pick_res_arr = get_world_2d().get_direct_space_state().intersect_point(global_aim_pos, 32, [], 2147483647, 31)
			#print(pick_res_arr)
			for picked_res in pick_res_arr :
				var picked_obj = picked_res.collider
				if(picked_obj.get_groups().has("corpse")):
					print("CORPSE!")
					dragging_thing = weakref(picked_res.collider)
				if(picked_obj.has_method("do_pickable")):
					picked_obj.do_pickable(self)
	else:
		dragging_thing = null
					
	if(dragging_thing != null && dragging_thing.get_ref()):
		dragging_thing.get_ref().set_linear_velocity((trimmed_global_aim_pos - dragging_thing.get_ref().get_global_pos())/delta)

	pass

func on_damage(dmg):
	health -= dmg
	#print("Ouchd! ", dmg)
	if(health < 0):
		if(!almost_dead):
			almost_dead = true
			get_node("mace_joint").queue_free()
			get_node("mace").add_to_group("corpse") #just for fun
			player.play("lost_something")
	if(health < -20):
		if(!dead):
			dead = true
			get_node("body/anim").play("death")
			print("You are dead")
			var rand = randi()%2
			print(rand)
			if(rand == 0):
				player.play("player_death")
			else:
				player.play("player_death2")

#func _input(event):
#	if (event.type==InputEvent.MOUSE_BUTTON && event.is_pressed()):
#		get_world_2d().get_direct_space_state().intersect_point()
#		print(event)
