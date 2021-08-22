extends Node2D


### SIGNALS 


func _on_Host_pressed() -> void:
	Sounds.play_menu()
	get_tree().change_scene("res://scenes/host/host.tscn")


func _on_Join_pressed() -> void:
	Sounds.play_menu()
	get_tree().change_scene("res://scenes/join/join.tscn")
