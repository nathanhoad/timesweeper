extends Node


signal join_failed
signal ready_to_play
signal disconnected


const PORT = 8070


var player_index: int = 1
var is_host: bool = false
var rematch_turn: int = -1


func host() -> void:
	# Generate random lobby code
	randomize()
	var s = "0123456789ABCDEF"
	var code = ""
	for _i in range(0, 6):
		code += s[rand_range(0, s.length())]
	
	Gotm.host_lobby(false)
	Gotm.lobby.name = code
	Gotm.lobby.hidden = false
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT)
	get_tree().set_network_peer(peer)
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	
	player_index = 1
	is_host = true


func join(code: String) -> void:
	var fetch = GotmLobbyFetch.new()
	fetch.filter_name = code
	var lobbies = yield(fetch.first(), "completed")

	if lobbies.size() == 0:
		emit_signal("join_failed")
		return
	
	var success = yield(lobbies[0].join(), "completed")
	if not success:
		emit_signal("join_failed")
		return
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(Gotm.lobby.host.address, PORT)
	get_tree().set_network_peer(peer)
	yield(get_tree(), "connected_to_server")
	
	player_index = 2
	is_host = false
	
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("server_disconnected", self, "_on_player_disconnected")
	
	emit_signal("ready_to_play")


### SIGNALS


func _on_player_connected(id: int) -> void:
	emit_signal("ready_to_play")


func _on_player_disconnected(id: int) -> void:
	emit_signal("disconnected")
