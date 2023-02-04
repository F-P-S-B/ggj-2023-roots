extends KinematicBody2D

export var jump_speed := 1000
export var gravity := 100
export var vert_friction := 0.025
export var horiz_friction := 0.2
export var max_speed := 350.0


enum Skills{
	MOVE,
	JUMP1,
	JUMP2,
	SUPER_JUMP,
	WALL_JUMP,
	GLIDING,
	DASH,
	RAISE_PLATFORM,
	LANTERN
}

export var enabled_skills := {
	Skills.MOVE : true,
	Skills.JUMP1 : true,
	Skills.JUMP2 : false,
	Skills.SUPER_JUMP : false,
	Skills.WALL_JUMP : false,
	Skills.GLIDING : false,
	Skills.DASH : false,
	Skills.RAISE_PLATFORM : false,
	Skills.LANTERN : false
}



var velocity := Vector2.ZERO
var direction := 1
var air_jumps := 0

func fall():
	velocity.y = (1-vert_friction)*velocity.y
	velocity.y += gravity
	
func move():
	if enabled_skills[Skills.MOVE] or (not is_on_floor()):
		if ((not Input.is_action_pressed("move_left")) and (not Input.is_action_pressed("move_right"))) or ((Input.is_action_pressed("move_left")) and (Input.is_action_pressed("move_right"))):
			velocity.x = lerp(velocity.x, 0, horiz_friction)
		elif Input.is_action_pressed("move_right"):
			direction = 1
			velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)
		elif Input.is_action_pressed("move_left"):
			direction = -1
			velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)
	else:
		velocity.x = lerp(velocity.x, 0, horiz_friction)

func jump():
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed
	
func super_jump():
	pass
	
func wall_jump():
	pass
	
func gliding():
	pass
	
func dash():
	pass
	
func raise_platform():
	pass
	
func lantern():
	pass
	
func _physics_process(_delta):
	if(is_on_floor()):
		pass
		#velocity.y = 0
	else:
		fall()
	if enabled_skills[Skills.JUMP1] or enabled_skills[Skills.JUMP2]:
		if enabled_skills[Skills.JUMP1] and enabled_skills[Skills.JUMP2]:
			if (is_on_floor()):
				air_jumps = 1
		jump()
	if enabled_skills[Skills.SUPER_JUMP]:
		super_jump()
	if enabled_skills[Skills.WALL_JUMP]:
		wall_jump()
	if enabled_skills[Skills.GLIDING]:
		gliding()
	if enabled_skills[Skills.DASH]:
		dash()
	if enabled_skills[Skills.RAISE_PLATFORM]:
		raise_platform()
	if enabled_skills[Skills.LANTERN]:
		lantern()
	velocity = move_and_slide(velocity, Vector2.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
