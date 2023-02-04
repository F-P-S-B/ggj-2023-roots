extends GridContainer


func _ready():
	var separation = 5
	add_constant_override("hseparation", separation)
	add_constant_override("vseparation", separation)
