extends Node2D


signal rematched


onready var label: Label = $Box/Label


var message: String = "" setget set_message


func set_message(value: String) -> void:
	label.text = value


func _on_Rematch_pressed():
	emit_signal("rematched")
