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

enum AnimationUnsquishState {
	DOESNT_MATTER,
	LANDING
}

"""
Config
"""
export var jump_speed := 300
export var air_jump_speed := 300
export var super_jump_speed := 800
export var super_jump_charge_duration := 120
export var wall_jump_duration := 5
export var wall_jump_speed := 200
export var dash_speed := 780
export var dash_duration := 4
export var dash_friction := 0.25

export var gravity := 20
export var gliding_gravity := 20
export var sliding_speed := 50
export var vert_friction := 0.025
export var horiz_friction := 0.2
export var max_speed := 150.0
export var max_skill_count := 5

const animation_unsquish_rate := 0.2
const animation_jump_squish := Vector2(0.55, 1.6)
const animation_land_max_squish := Vector2(1.5, 0.35)
const animation_land_min_squish_velocity := 20.0
const animation_land_max_squish_velocity := 600.0
const animation_dash_squish := Vector2(2.0, 0.7)
const animation_run_threshold := 50.0

export var enabled_skills := {
	Skills.MOVE : true,
	Skills.JUMP1 : true,
	Skills.JUMP2 : true,
	Skills.SUPER_JUMP : true,
	Skills.WALL_JUMP : true,
	Skills.GLIDING : true,
	Skills.DASH : true,
	Skills.RAISE_PLATFORM : true,
	Skills.LANTERN : true,
}

"""
Useful vars
"""
var velocity := Vector2.ZERO
var direction := 1
var air_jumps := 0
var dashes := 0
var dash_timer := 0
var wall_jump_timer := 0
var super_jump_countdown := super_jump_charge_duration
var show_menu := false
var skill_count : int
var skilltree : CenterContainer
var on_walls_right := 0
var on_walls_left := 0
var is_sliding := false
onready var animation_sprite_squisher := $SpriteWrapper
onready var animation_sprite := $SpriteWrapper/Sprite
onready var animation_player := $AnimationPlayer
var animation_unsquish_state = AnimationUnsquishState.DOESNT_MATTER

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
	animation_unsquish()
	if dash_timer == 0:
		animation_flip_to_direction()
	if super_jump():
		return
	if dash():
		return
	fall()
	#sliding()
	#if wall_jump():
	#	return
	move()
	jump()
	gliding()
	raise_platform()
	lantern()
	var __ = move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		animation_ground_squish()
		velocity.y = 0.0
	if is_on_ceiling():
		velocity.y = 0.0
	if is_on_wall():
		velocity.x = 0.0
	animation_decide()

"""
Movements and skills
"""
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
	if not (enabled_skills[Skills.JUMP1] or enabled_skills[Skills.JUMP2]):
		return
	if (enabled_skills[Skills.JUMP1] and 
		enabled_skills[Skills.JUMP2] and 
		is_on_floor()):
			air_jumps = 1
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed
			animation_squish(animation_jump_squish)
		else:
			if air_jumps >= 1:
				air_jumps -= 1
				velocity.y = -air_jump_speed
				animation_squish(animation_jump_squish)
	
func super_jump():
	if not enabled_skills[Skills.SUPER_JUMP]:
		return false
	if Input.is_action_pressed("super_jump") and is_on_floor():
		velocity.x = 0.0
		dash_timer = 0
		if super_jump_countdown > 0:
			super_jump_countdown -=1
		return true
	if super_jump_countdown == 0:
		air_jumps = 0
		velocity.y = -super_jump_speed
		velocity = move_and_slide(velocity, Vector2.UP)
	super_jump_countdown = super_jump_charge_duration
	return false
	
func sliding():	
	if not enabled_skills[Skills.WALL_JUMP]:
		return
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		return
	if enabled_skills[Skills.JUMP1] and enabled_skills[Skills.JUMP2] and is_on_floor():
		air_jumps = 1
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		velocity.y = sliding_speed
			
func wall_jump():
	if wall_jump_timer > 0:
		wall_jump_timer -= 1
		velocity.x = (-direction) * wall_jump_speed
		return true
	if not is_sliding:
		return false
	if Input.is_action_just_pressed("jump"):
		wall_jump_timer = wall_jump_duration - 1
		velocity.y -= jump_speed
		velocity.x = direction * wall_jump_speed
		return true
	
func gliding():
	if not enabled_skills[Skills.GLIDING]:
		return
	if Input.is_action_pressed("jump"):
		if (not is_on_floor()) and velocity.y > 0 :
			velocity.y += gliding_gravity - gravity
		
	
func dash():
	if dash_timer > 0:
		dash_timer -= 1
		velocity.y = 0
		velocity.x *= (1 - dash_friction)
		velocity = move_and_slide(velocity, Vector2.UP)
		animation_squish(animation_dash_squish)
		return true
		
	if not enabled_skills[Skills.DASH]:
		return false
		
	if(is_on_floor()):
		dashes = 1
	if Input.is_action_just_pressed("dash"):
		if(dashes >= 1):
			dashes -= 1
			dash_timer = dash_duration
			velocity.x = direction * dash_speed
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
Animation
"""
func animation_unsquish():
	animation_sprite_squisher.scale = animation_sprite_squisher.scale.linear_interpolate(
		Vector2(1.0, 1.0), animation_unsquish_rate
	)

func animation_squish(squishinnes: Vector2):
	animation_sprite_squisher.scale = squishinnes
	animation_unsquish_state = AnimationUnsquishState.DOESNT_MATTER

func animation_flip_to_direction():
	animation_set_direction(direction)

func animation_set_direction(d: float):
	animation_sprite.scale.x = d

func animation_ground_squish():
	var animation_squish_factor := clamp(
		(
			(velocity.y - animation_land_min_squish_velocity) /
			(animation_land_max_squish_velocity - animation_land_min_squish_velocity)
		),
		0.0,
		1.0
	)
	var animation_squish_amount: Vector2 = lerp(
		Vector2(1.0, 1.0),
		animation_land_max_squish,
		animation_squish_factor
	)
	if (
		animation_unsquish_state != AnimationUnsquishState.LANDING or
		animation_squish_amount.y < animation_sprite_squisher.scale.y
	):
		animation_squish(animation_squish_amount)
		animation_unsquish_state = AnimationUnsquishState.LANDING

func animation_decide():
	if is_on_floor():
		if abs(velocity.x) > animation_run_threshold:
			animation_player.play("Run")
			return
		animation_player.play("Idle")
		return
	animation_player.play("Jump")

"""
Signals
"""
func _on_WallJumpLeft_body_entered(_body : Node):
	on_walls_left += 1
	print("cas1")
	
func _on_WallJumpLeft_body_exited(_body : Node):
	on_walls_left -= 1
	print("cas2")
	
func _on_WallJumpRight_body_entered(_body : Node):
	on_walls_right += 1
	print("cas3")
	
func _on_WallJumpRight_body_exited(_body : Node):
	on_walls_right -= 1
	print("cas4")

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
