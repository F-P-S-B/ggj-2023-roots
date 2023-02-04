extends KinematicBody2D

export var jump_speed := 1000
export var gravity := 100
export var vert_friction := 0.025
export var horiz_friction := 0.2
export var max_speed := 350.0
export var max_skill_count := 2
var skill_count = 0

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
	Skills.MOVE : false,
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
	print(skill_count)
var velocity := Vector2.ZERO
var direction := 1
var air_jumps := 0


func fall():
	velocity.y = (1-vert_friction)*velocity.y
	velocity.y += gravity
	
func move():
	if not (enabled_skills[Skills.MOVE]) and is_on_floor():
		print(1)
		velocity.x = lerp(velocity.x, 0, horiz_friction)
		return 
	
	if (Input.is_action_pressed("move_left")) and (Input.is_action_pressed("move_right")):
		print(2)
		velocity.x = lerp(velocity.x, 0, horiz_friction)
		return
	if Input.is_action_pressed("move_right"):
		print(3)
		direction = 1
		velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)
		return
	if Input.is_action_pressed("move_left"):
		print(4)
		direction = -1
		velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)
		return
	print(5)
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
		velocity.y = 1
	else:
		fall()
	move()
	if enabled_skills[Skills.JUMP1] or enabled_skills[Skills.JUMP2]:
		if enabled_skills[Skills.JUMP1] and enabled_skills[Skills.JUMP2]:
			if (is_on_floor()):
				pass
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



func _on_DashButton_pressed():
	enable_skill(Skills.DASH)	


func _on_Jump1Button_pressed():
	enable_skill(Skills.JUMP1)


func _on_Jump2Button_pressed():
	enable_skill(Skills.JUMP2)


func _on_Super_JumpButton_pressed():
	enable_skill(Skills.SUPER_JUMP)


func _on_MoveButton_pressed():
	enable_skill(Skills.MOVE)


func _on_LanternButton_pressed():
	enable_skill(Skills.LANTERN)


func _on_Wall_JumpButton_pressed():
	enable_skill(Skills.DASH)


func _on_GlideButton_pressed():
	enable_skill(Skills.DASH)


func _on_PlatformButton_pressed():
	enable_skill(Skills.RAISE_PLATFORM)

func enable_skill(skill: int): # type: Enum Skills
	var value: bool = enabled_skills[skill]
	print(skill)
	print(value)
	if value:
		enabled_skills[skill] = false
		skill_count -= 1
		print(skill_count)
		print(enabled_skills[skill])
		return 
	if skill_count > max_skill_count:
		print("Dépasse")
		return
	enabled_skills[skill] = true
	skill_count += 1
	print(skill_count)
	print(enabled_skills[skill])
