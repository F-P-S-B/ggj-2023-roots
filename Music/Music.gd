extends AudioStreamPlayer


var on_loop_tail := false
var intentionally_playing := true


func _ready():
	connect("finished", self, "_on_Music_finished")
	stream = preload("res://Music/music_head.wav")

func start_music():
	if not intentionally_playing and not playing:
		return
	play()

func stop_music():
	intentionally_playing = false
	stop()
	stream = preload("res://Music/music_head.wav")
	on_loop_tail = false

func _on_Music_finished():
	if on_loop_tail:
		return
	if not intentionally_playing:
		return
	stream = preload("res://Music/music_tail.wav")
	play()
	on_loop_tail = true
