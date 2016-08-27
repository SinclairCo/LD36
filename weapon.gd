
extends RigidBody2D

var contact_pos = null
var dmg_factor

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
				body.on_damage(dmg)
	
#func _draw():
#	if(contact_pos != null):
#		draw_line( get_global_transform().xform_inv(contact_pos),  get_global_transform().xform_inv(contact_pos+dmg_factor), Color(1,1,1))

	