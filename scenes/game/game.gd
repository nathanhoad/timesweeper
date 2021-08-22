extends Node2D


const Modal = preload("res://components/modal/modal.tscn")
const PlusTime = preload("res://components/plus_time/plus_time.tscn")


export(AudioStreamSample) var new_game_sound
export(AudioStreamSample) var found_time_sound
export(AudioStreamSample) var your_turn_sound
export(AudioStreamSample) var win_sound
export(AudioStreamSample) var lose_sound


onready var board = $Board
onready var stats: Stats = $Stats
onready var player_1_name: Label = $Player1Rect/Name
onready var player_1_time: Label = $Player1Rect/Time
onready var player_1_pos: Position2D = $Player1Rect/ArrowPosition
onready var player_1_score_label: Label = $Player1Rect/Score
onready var player_2_name: Label = $Player2Rect/Name
onready var player_2_time: Label = $Player2Rect/Time
onready var player_2_pos: Position2D = $Player2Rect/ArrowPosition
onready var player_2_score_label: Label = $Player2Rect/Score
onready var timer: Timer = $Timer
onready var arrow: Node2D = $Arrow
onready var remaining: Label = $Bonus/Remainig
onready var tick_sound: AudioStreamPlayer = $Tick

var your_time: Label
var their_time: Label


func _ready() -> void:
	if Session.player_index == 1:
		player_1_name.text = "YOU"
		player_2_name.text = "THEM"
		your_time = player_1_time
		their_time = player_2_time
	else:
		player_2_name.text = "YOU"
		player_1_name.text = "THEM"
		your_time = player_2_time
		their_time = player_1_time
	
	Session.connect("disconnected", self, "_on_disconnect")
	
	remaining.text = str(board.remaining_hazards) + " REMAIN"
	Sounds.play(new_game_sound)


func start_timer() -> void:
	if timer.is_stopped():
		timer.start(1)


remotesync func end_game(who_won: int, did_run_out_of_time: bool = false) -> void:
	board.is_your_turn = false
	timer.stop()
	
	var modal = Modal.instance()
	add_child(modal)
	if who_won == Session.player_index:
		Sounds.play(win_sound)
		if did_run_out_of_time:
			modal.message = Constants.YOUR_OPPONENT_RAN_OUT_OF_TIME
			their_time.text = "0s"
		else:
			modal.message = Constants.YOU_WON.replace("{x}", str(stats.get_your_score()))
	else:
		Sounds.play(lose_sound)
		if did_run_out_of_time:
			modal.message = Constants.YOU_RAN_OUT_OF_TIME
			your_time.text = "0s"
		else:
			modal.message = Constants.YOU_LOST.replace("{x}", str(stats.get_your_score()))
			
	modal.connect("rematched", self, "_on_rematch")
	

remotesync func resign(who_resigned: int) -> void:
	board.is_your_turn = false
	timer.stop()
	
	var modal = Modal.instance()
	add_child(modal)
	if who_resigned == Session.player_index:
		Sounds.play(lose_sound)
		modal.message = Constants.YOU_RESIGNED
	else:
		Sounds.play(win_sound)
		modal.message = Constants.YOUR_OPPONENT_RESIGNED
	modal.connect("rematched", self, "_on_rematch")


remotesync func rematch() -> void:
	get_tree().change_scene("res://scenes/game/game.tscn")

### Signals


func _on_disconnect() -> void:
	get_tree().change_scene("res://scenes/disconnected/disconnected.tscn")


func _on_Stats_player_turn_changed(player_turn: int):
	var is_your_turn = player_turn == Session.player_index
	board.is_your_turn = is_your_turn
	
	if is_your_turn:
		Sounds.play(your_turn_sound)
	
	arrow.visible = true
	
	if player_turn == 1:
		arrow.global_position = player_1_pos.global_position
	else:
		arrow.global_position = player_2_pos.global_position


func _on_Board_chose_hazard(tile: Node2D):
	stats.add_point_to_current_player()
	start_timer()
	
	var plus_time = PlusTime.instance()
	plus_time.global_position = tile.get_center()
	add_child(plus_time)
	
	Sounds.play(found_time_sound)


func _on_Board_chose_number():
	stats.change_turn()
	start_timer()


func _on_Timer_timeout():
	var seconds_remaining = stats.tick()
	if stats.player_turn == Session.player_index:
		tick_sound.play()


func _on_Stats_player_times_changed(player_1_seconds, player_2_seconds):
	player_1_time.text = str(player_1_seconds) + "s"
	player_2_time.text = str(player_2_seconds) + "s"


func _on_Stats_player_1_wins():
	rpc("end_game", 1, true)


func _on_Stats_player_2_wins():
	rpc("end_game", 2, true)


func _on_Resign_pressed():
	Sounds.play_menu()
	rpc("resign", Session.player_index)


func _on_rematch() -> void:
	rpc("rematch")


func _on_Board_playable_tiles_changed(playable_tiles):
	remaining.text = str(board.remaining_hazards) + " REMAIN"
	player_1_score_label.text = str(stats.player_1_score)
	player_2_score_label.text = str(stats.player_2_score)


func _on_Stats_player_scores_changed(player_1_score, player_2_score):
	if player_1_score >= board.WINNING_HAZARD_COUNT:
		rpc("end_game", 1)
	elif player_2_score >= board.WINNING_HAZARD_COUNT:
		rpc("end_game", 2)
