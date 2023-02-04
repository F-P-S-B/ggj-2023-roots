extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
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

var enabled_skills := {
	Skills.MOVE : false,
	Skills.JUMP1 : false,
	Skills.JUMP2 : false,
	Skills.SUPER_JUMP : false,
	Skills.WALL_JUMP : false,
	Skills.GLIDING : false,
	Skills.DASH : false,
	Skills.RAISE_PLATFORM : false,
	Skills.LANTERN : false
}

export var vert_friction := 0.025
export var horiz_friction := 0.25
export var max_speed := 100.0

var velocity := Vector2.ZERO
var direction := 0

func move():
	direction = 0
	if Input.is_action_pressed("move_right"):
		direction = 1
	if Input.is_action_pressed("move_left"):
		direction = -1
	velocity.x = lerp(velocity.x, max_speed * direction, horiz_friction)

func jump():
	pass
	
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

func _ready():
	pass # Replace with function body.
	
func _physics_process(_delta):
	if enabled_skills[Skills.MOVE]:
		move()
	if enabled_skills[Skills.JUMP1] or enabled_skills[Skills.JUMP2]:
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
