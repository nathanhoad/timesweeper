class_name Stats
extends Node


signal player_turn_changed(player_turn)
signal player_scores_changed(player_1_score, player_2_score)
signal player_times_changed(player_1_seconds, player_2_seconds)
signal player_1_wins
signal player_2_wins


var player_turn: int = 1

var player_1_score: int = 0
var player_2_score: int = 0

var player_1_seconds: int = Constants.STARTING_SECONDS
var player_2_seconds: int = Constants.STARTING_SECONDS


func _ready() -> void:
	if Session.is_host:
		yield(get_tree(), "idle_frame")
		var initial_turn = rand_range(1, 3) if Session.rematch_turn == -1 else Session.rematch_turn
		Session.rematch_turn = 1 if initial_turn == 2 else 2
		rpc("set_turn", initial_turn)
	
	yield(get_tree(), "idle_frame")
	emit_signal("player_times_changed", player_1_seconds, player_2_seconds)


func get_your_score() -> int:
	if Session.player_index == 1:
		return player_1_score
	else:
		return player_2_score


remotesync func set_turn(value: int) -> void:
	player_turn = value
	emit_signal("player_turn_changed", player_turn)


func change_turn() -> void:
	player_turn = 1 if player_turn == 2 else 2
	emit_signal("player_turn_changed", player_turn)


func add_point_to_current_player() -> void:
	if player_turn == 1:
		player_1_score += 1
		player_1_seconds += Constants.SECONDS_PER_POINT
	else:
		player_2_score += 1
		player_2_seconds += Constants.SECONDS_PER_POINT
		
	emit_signal("player_scores_changed", player_1_score, player_2_score)


func tick() -> int:
	var current_seconds_remaining = INF
	
	if player_turn == 1:
		player_1_seconds -= 1
		current_seconds_remaining = player_1_seconds
	else:
		player_2_seconds -= 1
		current_seconds_remaining = player_2_seconds
	emit_signal("player_times_changed", player_1_seconds, player_2_seconds)
	
	if player_2_seconds == 0:
		emit_signal("player_1_wins")
	elif player_1_seconds == 0:
		emit_signal("player_2_wins")
	
	return current_seconds_remaining


func resign() -> void:
	if Session.player_index == 1:
		rpc("remote_resign", 2)
	else:
		rpc("remote_resign", 1)


remotesync func remote_resign(winner: int) -> void:
	if winner == 1:
		emit_signal("player_1_wins")
	else:
		emit_signal("player_2_wins")
