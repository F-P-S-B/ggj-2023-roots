extends KinematicBody2D

export var pred_path : NodePath
export var next_path : NodePath
var pred : KinematicBody2D = null
var next : KinematicBody2D = null
var number


"""
Test vars
"""
var pressed_pred := false
var pressed_next := false


"""
Main functions
"""
func _ready():
	var res := self.name.lstrip("RootTile")
	if res == "":
		res = "1"
	number = int(res)
	if number == 2:
		pred = get_node("../RootTile")
	if number > 2:
		pred = get_node("../RootTile"+str(number-1))
	next = get_node_or_null("../RootTile"+str(number+1))
	
func _physics_process(_delta):
	"""
	Testing/Dev code
	"""
	if Input.is_key_pressed(KEY_TAB):
		if !pressed_pred:
			pressed_pred = true
			if is_first():
				move_pred(Vector2.UP * 20)
		return
	pressed_pred = false
	if Input.is_key_pressed(KEY_BACKSPACE):
		if !pressed_next:
			pressed_next = true
			if is_first():
				move_next(Vector2.RIGHT * 20)
		return
	pressed_next = false

"""
Move functions
"""

func move_pred(move: Vector2):
	if !can_move_pred(move):
		return false 
	var r := find_first()
	move_pred_aux(r, r.position + move)


func move_next(move: Vector2):
	if !can_move_next(move):
		return false 
	var r := find_last()
	move_next_aux(r, r.position + move)






	
	
"""
Utilities
"""
func is_first() -> bool:
	return pred == null

func is_last() -> bool:
	return next == null

func is_empty(r: KinematicBody2D):
	return r == null
	
func find_first() -> KinematicBody2D:
	if self.is_first():
		return self
	return pred.find_first()

func find_last() -> KinematicBody2D:
	if self.is_last():
		return self
	return next.find_last()

func can_move_pred(_move: Vector2):
	return true #TODO
func move_pred_aux(r: KinematicBody2D, new_pos: Vector2):
	if is_empty(r):
		return
	var old_pos := Vector2(r.position.x, r.position.y)
	r.position = new_pos
	move_pred_aux(r.next, old_pos)


func can_move_next(_move: Vector2):
	return true #TODO
func move_next_aux(r: KinematicBody2D, new_pos: Vector2):
	if is_empty(r):
		return
	var old_pos := r.position
	r.position = new_pos
	move_next_aux(r.pred, old_pos)
