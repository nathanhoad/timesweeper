extends Node2D


onready var input_code: LineEdit = $InputCode
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var error: Label = $Error


var code: String = ""


func _ready() -> void:
	input_code.grab_focus()
	Session.connect("ready_to_play", self, "_on_ready_to_play")
	Session.connect("join_failed", self, "_on_join_failed")


### Signals


func _on_ready_to_play() -> void:
	get_tree().change_scene("res://scenes/game/game.tscn")


func _on_join_failed() -> void:
	input_code.editable = true
	animation_player.play("Error")
	error.visible = true


func _on_InputCode_text_changed(new_text: String) -> void:
	error.visible = false
	var caret_position = input_code.caret_position
	input_code.text = input_code.text.to_upper()
	input_code.caret_position = caret_position
	if new_text.length() == 6:
		input_code.editable = false
		Session.join(new_text)


func _on_Back_pressed():
	Sounds.play_menu()
	get_tree().change_scene("res://scenes/title/title.tscn")
