
extends RigidBody2D

var contact_pos = null
var dmg_factor

var blood = preload("res://effect_bloodhit.tscn") 

func _ready():
	#set_fixed_process(true)
	pass

func _fixed_process(delta):
	#update()
	pass

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var body = state.get_contact_collider_object(i)
		var shape = state.get_contact_local_shape(i)
		if(body.get("monster_tag") && shape == 0):
			#print("force ", state.get_contact_local_pos(i))
			contact_pos = state.get_contact_local_pos(i)
			var offset = contact_pos - get_global_pos()
			dmg_factor = get_linear_velocity() + (get_angular_velocity()*offset).rotated(PI/2)
			#print("dmg fac ", dmg_factor.length()/100)
			var dmg = dmg_factor.length()/100
			if(dmg > 10):
				if(body.on_damage(dmg)):
					var new_blood = blood.instance()
					new_blood.set_global_pos(contact_pos)
					get_tree().get_current_scene().add_child(new_blood)
					var sample = get_node("player")
					var sound_id = sample.play("hit")
					#sample.set_random_pitch_scale(10)
					sample.voice_set_pitch_scale(sound_id, (randf()-0.5)*0.5+1)
					sample.voice_set_volume_scale_db(sound_id, 1+dmg*dmg/100)
	
#func _draw():
#	if(contact_pos != null):
#		draw_line( get_global_transform().xform_inv(contact_pos),  get_global_transform().xform_inv(contact_pos+dmg_factor), Color(1,1,1))

	