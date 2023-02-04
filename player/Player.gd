extends KinematicBody2D

"""
Types
"""
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

"""
Config
"""
export var jump_speed := 1000
export var air_jump_speed := 1000
export var super_jump_speed := 2000
export var dash_speed := 1000
export var super_jump_charge = 200
export var gravity := 100
export var gliding_gravity := 50
export var vert_friction := 0.025
export var horiz_friction := 0.2
export var max_speed := 350.0
export var max_skill_count := 5

export var enabled_skills := {
	Skills.MOVE : false,
	Skills.JUMP1 : false,
	Skills.JUMP2 : false,
	Skills.SUPER_JUMP : false,
	Skills.WALL_JUMP : false,
	Skills.GLIDING : false,
	Skills.DASH : false,
	Skills.RAISE_PLATFORM : false,
	Skills.LANTERN : false,
}

"""
Useful vars
"""
var velocity := Vector2.ZERO
var direction := 1
var air_jumps := 0
var dashes := 0
var dash_timer := 0
var skill_count : int
var show_menu := false
var skilltree : CenterContainer
var on_wall_right := false
var on_wall_left := false

"""
Main functions
"""
func _ready():
	skill_count = calculate_skill_count()
	print("Skill count:", skill_count)
	skilltree = get_node("SkilltreeZFixer/Skilltree")
	

func _physics_process(_delta):
	if toggle_menu():
		return
	determine_direction()
	if dash():
		return
	fall()
	move()
	jump()
	super_jump()
	wall_jump()
	gliding()
	raise_platform()
	lantern()
	velocity = move_and_slide(velocity, Vector2.UP)
"""
Movements and skills
"""

func fall():
	velocity.y = (1-vert_friction)*velocity.y
	velocity.y += gravity
	if is_on_floor():
		velocity.y = 1
	
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
	if not (enabled_skills[Skills.JUMP1] or enabled_skills[Skills.JUMP2]):
		return
	if (enabled_skills[Skills.JUMP1] and 
		enabled_skills[Skills.JUMP2] and 
		is_on_floor()):
			air_jumps = 1
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed
		else:
			if air_jumps >= 1:
				air_jumps -= 1
				velocity.y = -air_jump_speed
	
func super_jump():
	if not enabled_skills[Skills.SUPER_JUMP]:
		return
	pass
	
func wall_jump():
	if not enabled_skills[Skills.WALL_JUMP]:
		return
	
	
func gliding():
	if not enabled_skills[Skills.GLIDING]:
		return
	if Input.is_action_pressed("jump"):
		if (not is_on_floor()) and velocity.y > 0 :
			velocity.y += gliding_gravity - gravity
		
	
func dash():
	if dash_timer > 0:
		dash_timer -= 1
		velocity.x = direction * dash_speed
		velocity.y = 0
		velocity = move_and_slide(velocity, Vector2.UP)
		return true
		
	if not enabled_skills[Skills.DASH]:
		return false
		
	if(is_on_floor()):
		dashes = 1
	if Input.is_action_just_pressed("dash"):
		if(dashes >= 1):
			dashes -= 1
			dash_timer = 5
		return true
	return false
	
func raise_platform():
	if not enabled_skills[Skills.RAISE_PLATFORM]:
		return
	pass

func lantern():
	if not enabled_skills[Skills.LANTERN]:
		return
	pass

"""
Signals
"""
func _on_Area2DGauche_body_entered(body : Node):
	print("body enterde bienn")	
	
func _on_Area2D2DROITE_body_entered(body : Node):
	print("111")

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


"""
Utilities
"""
func calculate_skill_count():
	var count = 0
	for skill in enabled_skills:
		count += int(enabled_skills[skill])
	return count

func toggle_menu():
	if Input.is_action_just_pressed("toggle_menu"):
		show_menu = not show_menu
	if show_menu:
		skilltree.show()
		return true
	skilltree.hide()
	return false
	
func determine_direction():
	if (Input.is_action_pressed("move_left")) and (Input.is_action_pressed("move_right")):
		return
	if Input.is_action_pressed("move_right"):
		direction = 1
		return
	if Input.is_action_pressed("move_left"):
		direction = -1

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
