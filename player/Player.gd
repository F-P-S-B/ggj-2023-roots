extends KinematicBody2D

export var jump_speed := 1000
export var air_jump_speed := 1000
export var super_jump_speed := 2000
export var dash_speed = 500
export var super_jump_charge = 200
export var gravity := 100
export var vert_friction := 0.025
export var horiz_friction := 0.2
export var max_speed := 350.0
export var max_skill_count := 5
var skill_count = 0
var show_menu = false
var skilltree
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
	Skills.LANTERN : false,
}
func calculate_skill_count():
	var count = 0
	for skill in enabled_skills:
		count += int(enabled_skills[skill])
	return count

func _ready():
	skill_count = calculate_skill_count()
	print("Skill count:", skill_count)
	skilltree = get_node("Skilltree")
	
	
var velocity := Vector2.ZERO
var direction := 1
var air_jumps := 0
var dashes := 0
var dash_timer := 0


func fall():
	velocity.y = (1-vert_friction)*velocity.y
	velocity.y += gravity
	
func move():
	if not (enabled_skills[Skills.MOVE]) and is_on_floor():
		velocity.x = lerp(velocity.x, 0, horiz_friction)
		return 
	
	if (Input.is_action_pressed("move_left")) and (Input.is_action_pressed("move_right")):
		velocity.x = lerp(velocity.x, 0, horiz_friction)
		return
	if Input.is_action_pressed("move_right"):
		direction = 1
		velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)
		return
	if Input.is_action_pressed("move_left"):
		direction = -1
		velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)
		return
	velocity.x = lerp(velocity.x, 0, horiz_friction)


func jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed
		else:
			if air_jumps >= 1:
				air_jumps -= 1
				velocity.y = -air_jump_speed
	
func super_jump():
	pass
	
func wall_jump():
	pass
	
func gliding():
	pass
	
func dash():
	if Input.is_action_just_pressed("dash"):
		if(dashes >= 1):
			dashes -= 1
			velocity.x = direction * dash_speed
	
func raise_platform():
	pass
	
func lantern():
	pass
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("toggle_menu"):
		show_menu = not show_menu
	if show_menu:
		skilltree.show()
		return
	skilltree.hide()
	
	
	if(is_on_floor()):
		velocity.y = 1
	else:
		fall()
	move()
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
		if(is_on_floor()):
			dashes = 1
		dash()
	if enabled_skills[Skills.RAISE_PLATFORM]:
		raise_platform()
	if enabled_skills[Skills.LANTERN]:
		lantern()
	velocity = move_and_slide(velocity, Vector2.UP)



func _on_Dash_Button_pressed():
	enable_skill(Skills.DASH)

func _on_Jump1_Button_pressed():
	enable_skill(Skills.JUMP1)

func _on_Jump2_Button_pressed():
	enable_skill(Skills.JUMP2)

func _on_Super_Jump_Button_pressed():
	enable_skill(Skills.SUPER_JUMP)

func _on_Move_Button_pressed():
	enable_skill(Skills.MOVE)

func _on_Lantern_Button_pressed():
	enable_skill(Skills.LANTERN)

func _on_Wall_Jump_Button_pressed():
	enable_skill(Skills.WALL_JUMP)

func _on_Glide_Button_pressed():
	enable_skill(Skills.GLIDING)

func _on_Platform_Button_pressed():
	enable_skill(Skills.RAISE_PLATFORM)

func enable_skill(skill: int): # type: Enum Skills
	if enabled_skills[skill]:
		enabled_skills[skill] = false
		skill_count -= 1
		print("Skill count:", skill_count)
		return 
	if skill_count >= max_skill_count:
		return
	enabled_skills[skill] = true
	skill_count += 1
	print("Skill count:", skill_count)
