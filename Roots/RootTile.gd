extends KinematicBody2D

var pred : KinematicBody2D = null
var next : KinematicBody2D = null
var number
const TILE_SIZE = 16

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
				move_pred(Vector2.UP * TILE_SIZE)
		return
	pressed_pred = false
	if Input.is_key_pressed(KEY_BACKSPACE):
		if !pressed_next:
			pressed_next = true
			if is_first():
				move_next(Vector2.UP * TILE_SIZE)
		return
	pressed_next = false

"""
Move functions
"""

func move_pred(move: Vector2):
	var r := find_first()
	if !can_move_pred(r, move):
		return false 
	move_pred_aux(r, r.position + move)


func move_next(move: Vector2):
	var r := find_last()
	if !can_move_next(r, move):
		return false 
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

func can_move_pred(r: KinematicBody2D, move: Vector2):
	if is_empty(r):
		return true
	if r.is_first():
		return (is_free_root(r.position + move)
			and is_free_platform(r.position + move)
			and can_move_pred(r.next, r.position - r.next.position))
	if r.is_last():
		return is_free_platform(r.position + move)
	#if r.platform != null:  	# Pseudocode
	#	return (is_free_platform(r.position + move) 
	#		and can_move_pred(r.next, r.position - r.next.position))
	return can_move_pred(r.next, r.position - r.next.position)
		
func is_free_root(_pos: Vector2):
	return true
func is_free_platform(_pos: Vector2):
	return true


func move_pred_aux(r: KinematicBody2D, new_pos: Vector2):
	if is_empty(r):
		return
	var old_pos := Vector2(r.position.x, r.position.y)
	r.position = new_pos
	move_pred_aux(r.next, old_pos)


func can_move_next(r: KinematicBody2D, move: Vector2):
	if is_empty(r):
		return true
	if r.is_last():
		return (is_free_root(r.position + move)
			and is_free_platform(r.position + move)
			and can_move_next(r.pred, r.position - r.pred.position))
	if r.is_first():
		return is_free_platform(r.position + move)
	#if r.platform != null:  	# Pseudocode
	#	return (is_free_platform(r.position + move) 
	#		and can_move_next(r.pred, r.position - r.pred.position))
	return can_move_next(r.pred, r.position - r.pred.position)
func move_next_aux(r: KinematicBody2D, new_pos: Vector2):
	if is_empty(r):
		return
	var old_pos := r.position
	r.position = new_pos
	move_next_aux(r.pred, old_pos)
