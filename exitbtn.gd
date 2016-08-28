
extends TextureButton
var currentScene = null
# member variables here, example:
# var a=2
# var b="textvar"
func _pressed():
	   get_tree().quit()
	   print("pressed")
	   #clean up the current scene
	 #  currentScene.queue_free()
	   #load the file passed in as the param "scene"
	   #create an instance of our scene

	   # add scene to root
	 #  get_tree().get_root().add_child(currentScene)

func _ready():
	# currentScene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)
	# Called every time the node is added to the scene.
	# Initialization here
	pass

	