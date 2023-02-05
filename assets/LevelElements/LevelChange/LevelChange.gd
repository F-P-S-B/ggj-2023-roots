extends Area2D


export var next_level: String

var player_in_range := false

	
func _physics_process(_delta):
	if player_in_range:	
		if Input.is_action_just_pressed("interact"):
			print(next_level)
			get_tree().change_scene(next_level)


func _on_LevelChange_area_entered(area):
	print("entered")
	player_in_range = true

func _on_LevelChange_area_exited(area):
	player_in_range = false
