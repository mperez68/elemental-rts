extends Node

enum { THEME, NONE }
enum State { INTRO, LOOP }

@onready var theme: Array[Array] = [ [$ThemeIntro, $ThemeLoop] ]
var current_song = NONE


func play(song: int, force_stop: bool = false):
	if song == current_song and !force_stop:
		return
	
	for track in get_children():
		track.stop()
	
	theme[song][State.INTRO].play()


func _on_theme_finished(song: int) -> void:
	theme[song][State.LOOP].play()
