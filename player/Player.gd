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
export var wall_jump_duration := 3
export var wall_jump_horiz_speed := 300
export var dash_speed := 1000
export var dash_duration := 4
export var dash_friction := 0.25

export var gravity := 20
export var gliding_gravity := 5
export var sliding_speed := 35
export var vert_friction := 0.0
export var horiz_friction := 0.2
export var max_speed := 150.0
export var max_skill_count := 9

const animation_unsquish_rate := 0.2
const animation_jump_squish := Vector2(0.55, 1.6)
const animation_land_max_squish := Vector2(1.5, 0.35)
const animation_land_min_squish_velocity := 20.0
const animation_land_max_squish_velocity := 600.0
const animation_dash_squish := Vector2(2.0, 0.7)
const animation_run_threshold := 50.0

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
var wall_jump_timer := 0
var super_jump_countdown := super_jump_charge_duration
var show_menu := false
var skill_count : int
var skilltree : Node2D
var on_walls_right := 0
var on_walls_left := 0
var can_wall_jump := 0 # 0 = cannot ; -1 = can left ; 1 = can right
var can_wall_jump_timer := 0

var can_open_menu := 0

var is_dying := false
onready var animation_sprite_squisher := $SpriteWrapper
onready var animation_sprite := $SpriteWrapper/Sprite
onready var animation_player := $AnimationPlayer
var animation_unsquish_state = AnimationUnsquishState.DOESNT_MATTER

var interactibles_within_reach = []

# Boutons
onready var dash_button := $"SkilltreeZFixer/Dash Button"
onready var jump1_button := $"SkilltreeZFixer/Jump1 Button"
onready var jump2_button := $"SkilltreeZFixer/Jump2 Button"
onready var lantern_button := $"SkilltreeZFixer/Lantern Button"
onready var move_button := $"SkilltreeZFixer/Move Button"
onready var glide_button := $"SkilltreeZFixer/Glide Button"
onready var super_jump_button := $"SkilltreeZFixer/Super Jump Button"
onready var platform_button := $"SkilltreeZFixer/Platform Button"
onready var wall_jump_button := $"SkilltreeZFixer/Wall Jump Button"
onready var text_label : RichTextLabel= $"SkilltreeZFixer/RichTextLabel"
onready var description_title : Label= $"SkilltreeZFixer/RichTextLabel/Title"
onready var description_label : Label= $"SkilltreeZFixer/RichTextLabel/Label"
onready var description_image : TextureRect= $"SkilltreeZFixer/RichTextLabel/TextureRect"
var last_hovered := -1

# Sons
var t : AudioStreamPlayer2D
var sound_player_list := [t]
var current_player_index := 0
var bird_timer := 0
var bird_count := 0
var drop_timer := 0
var drop_count := 0

"""
Main functions
"""
func _ready():
	skill_count = calculate_skill_count()
	skilltree = get_node("SkilltreeZFixer")
	
	change_icon(Skills.DASH, "dash", dash_button)
	change_icon(Skills.JUMP1, "jump", jump1_button)
	change_icon(Skills.JUMP2, "jump", jump2_button)
	change_icon(Skills.SUPER_JUMP, "super_jump", super_jump_button)
	change_icon(Skills.MOVE, "move", move_button)
	change_icon(Skills.LANTERN, "lantern", lantern_button)
	change_icon(Skills.WALL_JUMP, "wall_jump", wall_jump_button)
	change_icon(Skills.GLIDING, "glide", glide_button)
	change_icon(Skills.RAISE_PLATFORM, "platform", platform_button)
	
	sound_player_list[0] = AudioStreamPlayer2D.new()
	for __ in range(1, 60):
		sound_player_list.append(AudioStreamPlayer2D.new())
	

func _physics_process(_delta):
	play_sound()
	check_hover()
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
	sliding()
	if wall_jump():
		return
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
	if enabled_skills[Skills.WALL_JUMP]:
		if (on_walls_left == 0) and (on_walls_right == 0):
			can_wall_jump = 0
		if on_walls_left > 0:
			can_wall_jump = -1
			if Input.is_action_pressed("move_left"):
				velocity.y = sliding_speed
				if enabled_skills[Skills.JUMP1] and enabled_skills[Skills.JUMP2]:
					air_jumps = 1
				if enabled_skills[Skills.DASH]:
					dashes = 1
				return
		if on_walls_right > 0:
			can_wall_jump = 1
			if Input.is_action_pressed("move_right"):
				velocity.y = sliding_speed
				if enabled_skills[Skills.JUMP1] and enabled_skills[Skills.JUMP2]:
					air_jumps = 1
				if enabled_skills[Skills.DASH]:
					dashes = 1
			
func wall_jump():
	if wall_jump_timer > 0:
		wall_jump_timer -= 1
		velocity = move_and_slide(velocity, Vector2.UP)
		return true
	if (Input.is_action_just_pressed("jump")) and (can_wall_jump != 0):
		wall_jump_timer = wall_jump_duration - 1
		velocity.y -= jump_speed
		velocity.x = (-can_wall_jump) * wall_jump_horiz_speed
		velocity = move_and_slide(velocity, Vector2.UP)
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
	
func death():
	is_dying = true
	get_tree().reload_current_scene()

func interact():
	# Il faut créer un node qui a un Area2D sur le layer 7 (Interactibles)
	# et implémenter la méthode get_interactible_type qui renvoie un str: le type
	# de l'interactible
	# Après faire ce que vous voulez dans le match
	if len(interactibles_within_reach) == 0:
		return
	var closest = interactibles_within_reach[0]
	var closests_distance_squared = (
		closest.global_position - global_position
	).length_squared()
	for interactible in interactibles_within_reach:
		var distance_squared = (
			interactible.global_position - global_position
		).length_squared()
		if distance_squared >= closests_distance_squared:
			return
		closests_distance_squared = distance_squared
		closest = interactible
	match closest.get_interactible_type(): # str
		"Test":
			print("Test")
		_:
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
Sounds
"""
func play_sound():
	var player: AudioStreamPlayer2D = sound_player_list[current_player_index]
	if bird_timer <= 0:
		if bird_count > 0:
			# TODO: play
			update_player_index()
			bird_timer = int(rand_range(1, 2) * 60)
			bird_count -= 1
		else:
			bird_count = int(rand_range(0, 2))
			bird_timer = int(rand_range(30, 120) * 60)
			
		
	if drop_timer <= 0:
		if drop_count > 0:
			# TODO: play
			update_player_index()
			drop_timer = int(rand_range(30, 90))
			drop_count -= 1
		else:
			drop_count = int(rand_range(0, 5))
			drop_timer = int(rand_range(30, 100) * 60)

"""
Signals
"""
func _on_WallJumpLeft_body_entered(_body : Node):
	on_walls_left += 1
	
func _on_WallJumpLeft_body_exited(_body : Node):
	on_walls_left -= 1
	
func _on_WallJumpRight_body_entered(_body : Node):
	on_walls_right += 1
	
func _on_WallJumpRight_body_exited(_body : Node):
	on_walls_right -= 1
	
func _on_HitBox_area_entered(_body):
	death()
	
func _on_InteractStele_area_entered(_body : Node):
	can_open_menu += 1

func _on_InteractStele_area_exited(_body : Node):
	can_open_menu -= 1

func _on_Dash_Button_pressed():
	enable_skill(Skills.DASH)
	change_icon(Skills.DASH, "dash", dash_button)

func _on_Jump1_Button_pressed():
	enable_skill(Skills.JUMP1)
	change_icon(Skills.JUMP1, "jump", jump1_button)
	

func _on_Jump2_Button_pressed():
	enable_skill(Skills.JUMP2)
	change_icon(Skills.JUMP2, "jump", jump2_button)

func _on_Super_Jump_Button_pressed():
	enable_skill(Skills.SUPER_JUMP)
	change_icon(Skills.SUPER_JUMP, "super_jump", super_jump_button)
	

func _on_Move_Button_pressed():
	enable_skill(Skills.MOVE)
	change_icon(Skills.MOVE, "move", move_button)

func _on_Lantern_Button_pressed():
	enable_skill(Skills.LANTERN)
	change_icon(Skills.LANTERN, "lantern", lantern_button)

func _on_Wall_Jump_Button_pressed():
	enable_skill(Skills.WALL_JUMP)
	change_icon(Skills.WALL_JUMP, "wall_jump", wall_jump_button)

func _on_Glide_Button_pressed():
	enable_skill(Skills.GLIDING)
	change_icon(Skills.GLIDING, "glide", glide_button)

func _on_Platform_Button_pressed():
	enable_skill(Skills.RAISE_PLATFORM)
	change_icon(Skills.RAISE_PLATFORM, "platform", platform_button)

func _on_Interactible_enter(interactible: Node):
	# Créer un Area2D sur le layer 7: Interactible
	# Implémenter la fonction get_interactible_type sinon crash :3
	# Faire ce que vous voulez dans le match
	interactibles_within_reach.push_back(interactible)

func _on_Interactible_leave(interactible: Node):
	var index = interactibles_within_reach.find(interactible)
	if index != -1:
		interactibles_within_reach.pop_at(index)

"""
Utilities
"""
func calculate_skill_count():
	var count = 0
	for skill in enabled_skills:
		count += int(enabled_skills[skill])
	return count
	
func check_hover():
	if not show_menu:
		return
	var buttons = [
					dash_button, jump1_button, jump2_button, 
					lantern_button, move_button, glide_button,
					super_jump_button, platform_button, wall_jump_button
				]
	var names = [
				"dash", "jump", "jump",
				"lantern", "move", "glide",
				"super_jump", "platform", "wall_jump"
			]
	var descriptions = [
		"Allows you to dash forward by pressing shift",
		"Grants you one extra jump",
		"Grants you one extra jump",
		"Guides your path through the darkness, costs 1800g, (TODO: implement currency)",
		"Allows you to move while on the floor",
		"Allows you to glide through the air, by holding space",
		"Grants you a super jump, by holding ctrl for 2 seconds and then releasing",
		"Summons a platform above your head",
		"Grants you the ability to wall jump/slide"
	]

	for i in range(0, buttons.size()):
		if buttons[i].is_hovered():
			if i == last_hovered:
				return
			last_hovered = i
			text_label.show()
			description_image.texture = load("player/buttons/" + names[i] + ".png")
			description_title.text = names[i].rsplit("_").join(" ").capitalize()
			description_label.text = descriptions[i]
			return
	text_label.hide()
	last_hovered = -1

func toggle_menu():
	if Input.is_action_just_pressed("toggle_menu") and (show_menu or (can_open_menu > 0)):
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
		return 
	if skill_count >= max_skill_count:
		return
	enabled_skills[skill] = true
	skill_count += 1

func change_icon(skill: int, skillname: String, button: TextureButton):
	if enabled_skills[skill]:
		skillname += "_act"
	var button_name = "player/buttons/" + skillname + ".png"
	button.texture_normal = load(button_name)
	button.texture_pressed = load(button_name)
	button.texture_hover = load(button_name)
	
func update_player_index():
	current_player_index = (current_player_index + 1)%60

