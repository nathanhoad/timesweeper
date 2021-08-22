extends Node2D


onready var code_label: Label = $Code


func _ready():
	Session.connect("ready_to_play", self, "_on_ready_to_play")
	
	Session.host()
	code_label.text = Gotm.lobby.name


func _on_ready_to_play() -> void:
	get_tree().change_scene("res://scenes/game/game.tscn")


func _on_Code_gui_input(event):
	OS.set_clipboard(Gotm.lobby.name)


func _on_Back_pressed():
	Sounds.play_menu()
	get_tree().change_scene("res://scenes/title/title.tscn")
