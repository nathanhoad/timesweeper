extends Node


const MENU_SOUND = preload("res://assets/sounds/menu.wav")


onready var audio: AudioStreamPlayer = $AudioStreamPlayer


func play(resource) -> void:
	assert(resource != null, "You are trying to play a null sound")
	audio.stream = resource
	audio.play()


func play_menu() -> void:
	play(MENU_SOUND)
