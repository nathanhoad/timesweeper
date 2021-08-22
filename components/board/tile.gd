tool

extends Node2D


signal hovered(tile)
signal actioned(index)


export var index: int setget set_index


onready var color_rect: ColorRect = $ColorRect
onready var label: Label = $Label
onready var clock: Sprite = $Clock


var state := Constants.BLOCK_STATE_UNKNOWN setget set_state


func _ready() -> void:
	self.index = index


func get_center() -> Vector2:
	return global_position + color_rect.rect_size / 2


func set_index(value: int) -> void:
	index = value
	if color_rect != null:
		if index % 2 == 0:
			color_rect.color = Constants.COLOR_UNKNOWN
		else:
			color_rect.color = Constants.COLOR_UNKNOWN_ALT


func set_state(value) -> void:
	if value == state:
		return

	state = value
	match state:
		Constants.BLOCK_STATE_UNKNOWN:
			if index % 2 == 0:
				color_rect.color = Constants.COLOR_UNKNOWN
			else:
				color_rect.color = Constants.COLOR_UNKNOWN_ALT
		
		Constants.BLOCK_STATE_PLAYER_1:
			clock.visible = true
			color_rect.color = Constants.COLOR_PLAYER_1
	
		Constants.BLOCK_STATE_PLAYER_2:
			clock.visible = true
			color_rect.color = Constants.COLOR_PLAYER_2
		
		_:
			color_rect.color = Constants.COLOR_NUMBER
			label.text = state if state != Constants.BLOCK_STATE_0 else ""


### SIGNALS


func _on_board_changed(playable_tiles: Array) -> void:
	self.state = playable_tiles[index]


func _on_ColorRect_gui_input(event: InputEventMouse) -> void:
	if event == null: return
	if state != Constants.BLOCK_STATE_UNKNOWN: return
	
	if event.is_pressed() and event.button_index == 1:
		emit_signal("actioned", index)


func _on_ColorRect_mouse_entered() -> void:
	emit_signal("hovered", self)
