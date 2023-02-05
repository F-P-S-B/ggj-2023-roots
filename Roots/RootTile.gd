extends KinematicBody2D
export var platform_path := ""
var pred : KinematicBody2D = null
var next : KinematicBody2D = null
var platform : KinematicBody2D = null
var number
const TILE_SIZE = 16
enum Dir {
	PRED,
	NEXT
}

"""
Test vars
"""
var pressed_pred := false
var pressed_next := false


"""
Main functions
"""
func _ready():
	platform = get_node_or_null(platform_path)
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
				move()
		return
	pressed_pred = false
	if Input.is_key_pressed(KEY_BACKSPACE):
		if !pressed_next:
			pressed_next = true
			if is_first():
				move()
		return
	pressed_next = false

"""
Move functions
"""
func move():
	#if ((!is_empty(pred) and pred.position.y == position.y) 
	 #&& (!is_empty(next) and next.position.y == position.y)):
		#return false
	#if is_first() or pred.position.x > position.x or (!is_empty(next) and next.position.x < position.x):
		#bouger vers pred
	#	return move_pred()
	#bouger vers next
	#return move_next()
	if closest_first():
		move_pred(Vector2.UP * 8)
		return
	move_next(Vector2.UP * 8)
func closest_first():
	var dl := 0
	var r := self 
	while !is_empty(r):
		r = r.next
		dl+=1
	var dd := 0
	r = self 
	while !is_empty(r):
		r = r.pred
		dd+=1
	return dl > dd
	
func can_move_up_pred():
	var platform_can_move := true
	if platform != null:
		platform_can_move = platform.test_move(Transform2D(0.0, platform.position), Vector2.UP * 64)
	if is_first():
		return platform_can_move
	return platform_can_move && pred.can_move_up_pred()
		
func move_up_pred():
	position += Vector2.UP *64
	if self.is_first():
		return
	pred.move_up_pred()

func move_pred(d):
	if !can_move_up_pred() or (!is_last() and !can_move_pred(next, position - next.position)):
		return false
	var pos := position 
	#move_up_pred()
	var r = find_first()
	move_pred_aux(r, r.position + d)


func can_move_up_next():
	var platform_can_move := true
	if platform != null:
		platform_can_move = platform.test_move(Transform2D(0.0, platform.position), Vector2.UP * 64)
	if is_last():
		return platform_can_move
	return platform_can_move && next.can_move_up_next()
		
func move_up_next():
	position += Vector2.UP *64
	if is_last():
		return
	next.move_up_next()

func move_next(dir):
	if !can_move_up_next() or (!is_first() and !can_move_next(pred, position - pred.position)):
		return false
	var pos := position 
	#move_up_next()
	var r = find_last()
	
	move_next_aux(r, r.position + dir)


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
	# A tester, j'ai aucune idée de ce que je fais
	if is_empty(r):
		return true

	var platform_can_move := true
	if r.platform != null:
		platform_can_move = r.platform.test_move(Transform2D(0.0, r.platform.position), move)  

	if r.is_first(): 
		return (platform_can_move
			and r.test_move(Transform2D(0.0, r.position), move)
			and can_move_pred(r.next, r.position - r.next.position))
	if r.is_last():
		return platform_can_move
	
	return platform_can_move and can_move_pred(r.next, r.position - r.next.position)


func move_pred_aux(r: KinematicBody2D, new_pos: Vector2):
	if is_empty(r):
		return
	var old_pos := Vector2(r.position.x, r.position.y)
	r.position = new_pos
	move_pred_aux(r.next, old_pos)


func can_move_next(r: KinematicBody2D, move: Vector2):
	# A tester, j'ai aucune idée de ce que je fais
	if is_empty(r):
		return true

	var platform_can_move := true
	if r.platform != null:
		platform_can_move = r.platform.test_move(Transform2D(0.0, r.platform.position), move)  

	if r.is_last(): 
		return (platform_can_move
			and r.test_move(Transform2D(0.0, r.position), move)
			and can_move_next(r.pred, r.position - r.next.position))
	if r.is_last():
		return platform_can_move
	
	return platform_can_move and can_move_next(r.pred, r.position - r.next.position)
	
func move_next_aux(r: KinematicBody2D, new_pos: Vector2):
	if is_empty(r):
		return
	var old_pos := r.position
	r.position = new_pos
	move_next_aux(r.pred, old_pos)
