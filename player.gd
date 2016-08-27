
extends RigidBody2D

var run_speed = 700
var acceleration = 5000;
var jump_imp = 2300;

var next_jump_delay = 0.080;
var current_jump_delay = 0;

var mace_base_last_pos = Vector2(0,0)

var max_arm_length = 0

var look_right = false

var health = 100

func _ready():
	set_fixed_process(true)
	max_arm_length = (get_node("max_arm_length").get_global_pos() - get_node("body/arms").get_global_pos()).length()
	pass
	
func _fixed_process(delta):
	
	#########################################
	####MOVE AND JUMP########################
	#########################################
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var direction = Vector2((right - left), 0).normalized()
	
	var is_moving = direction.x != 0
	if(is_moving):
		look_right = direction.x > 0
	
	if(!is_moving):
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
	var arms_base_pos = get_node("body/arms").get_global_pos()
	var direction_from_shoulder = global_aim_pos - arms_base_pos
	if(direction_from_shoulder.length() > max_arm_length):
		direction_from_shoulder = direction_from_shoulder.normalized()*max_arm_length
		global_aim_pos = arms_base_pos + direction_from_shoulder
	
	var mace_base = get_node("mace_joint_base")
	#change position with velocity to have accurate joint simulation
	mace_base.set_linear_velocity((global_aim_pos - mace_base.get_global_pos())/delta)
	
	#rotate arms... manually
	var sin_a = direction_from_shoulder.length()/2/(max_arm_length/2)
	var asin_a = PI/2
	if(sin_a <= 0.999):
		 asin_a = asin(sin_a)
	var shoulder_angle = PI/2 - asin_a
	
	#print(shoulder_angle, " " , direction_from_shoulder.length()/2, " " , max_arm_length/2, " ", direction_from_shoulder.length()/2/(max_arm_length/2))
	if(look_right):
		get_node("body/arms").set_rot(-direction_from_shoulder.angle() + PI/2);
	else:
		get_node("body/arms").set_rot(direction_from_shoulder.angle() + PI/2);
	get_node("body/arms/shoulder").set_rot(shoulder_angle)
	get_node("body/arms/shoulder/hand_arm").set_rot(PI + (PI/2 - shoulder_angle)*2)
			
	pass

func on_damage(dmg):
	health -= dmg
	print("Ouchd! ", dmg)
	if(health < 0):
		print("You are dead")

