extends Node2D


func _on_Back_pressed():
	Sounds.play_menu()
	get_tree().change_scene("res://scenes/title/title.tscn")
