extends Node2D


signal chose_hazard(tile)
signal chose_number()
signal playable_tiles_changed(playable_tiles)


const Tile = preload("res://components/board/tile.tscn")


const WIDTH = 15
const HEIGHT = 15
const SIZE = WIDTH * HEIGHT
const HAZARD_COUNT = 51
const WINNING_HAZARD_COUNT = 26

const TILE_WIDTH = 70
const TILE_HEIGHT = 70


export var _stats: NodePath = NodePath()


onready var stats: Stats = get_node(_stats)
onready var cursor: Node2D = $Cursor


var tiles: Array
var playable_tiles: Array
var remaining_hazards: int = HAZARD_COUNT

var is_your_turn: bool = false setget set_is_your_turn


func _ready() -> void:
	# Only generate board if we are the host
	if Session.player_index == 1:
		generate_board()
	
	for tile in $Tiles.get_children():
		tile.connect("hovered", self, "_on_tile_hovered")
		tile.connect("actioned", self, "_on_tile_actioned")
		connect("playable_tiles_changed", tile, "_on_board_changed")


func set_is_your_turn(value: bool) -> void:
	is_your_turn = value
	cursor.visible = is_your_turn
	

func generate_board(premade_tiles: Array = []) -> void:
	# Make an empty grid
	tiles = []
	playable_tiles = []
	for _i in range(0, SIZE):
		tiles.append(Constants.BLOCK_STATE_UNKNOWN)
		playable_tiles.append(Constants.BLOCK_STATE_UNKNOWN)
	
	# We are the joining player to just use the board we already have
	if premade_tiles.size() > 0:
		tiles = premade_tiles
		return

	randomize()

	# Place hazards
	remaining_hazards = HAZARD_COUNT
	for _b in range(0, HAZARD_COUNT):
		var index = rand_range(0, SIZE)
		# Ignore this index if its already a hazard
		while tiles[index] == Constants.BLOCK_STATE_HAZARD:
			index = rand_range(0, SIZE)
		tiles[index] = Constants.BLOCK_STATE_HAZARD

	# Place hint numbers
	for i in range(0, SIZE):
		var count = 0
		if tiles[i] == Constants.BLOCK_STATE_UNKNOWN:
			# Above
			if not is_left_edge(i) and is_hazard(i - WIDTH - 1): count += 1
			if is_hazard(i - WIDTH): count += 1
			if not is_right_edge(i) and is_hazard(i - WIDTH + 1): count += 1
			
			# left/right (ignore wrapping)
			if not is_left_edge(i) and is_hazard(i - 1): count += 1
			if not is_right_edge(i) and is_hazard(i + 1): count += 1
			
			# below
			if not is_left_edge(i) and is_hazard(i + WIDTH - 1): count += 1
			if is_hazard(i + WIDTH): count += 1
			if not is_right_edge(i) and is_hazard(i + WIDTH + 1): count += 1

			tiles[i] = str(count)
	
	rpc("sync_board", tiles)


remote func sync_board(premade_tiles: Array) -> void:
	generate_board(premade_tiles)


# Reveals any tiles that need revealing
remotesync func reveal(index: int) -> void:
	var chose_number = ripple_reveal(index)
	if chose_number:
		emit_signal("chose_number")
	emit_signal("playable_tiles_changed", playable_tiles)
	

func ripple_reveal(index: int) -> bool:
	if index < 0 or index >= SIZE:
		return false
	if playable_tiles[index] != Constants.BLOCK_STATE_UNKNOWN:
		return false
	if index < 0 or index >= SIZE:
		return false
	
	match tiles[index]:
		Constants.BLOCK_STATE_HAZARD:
			emit_signal("chose_hazard", $Tiles.get_children()[index])
			remaining_hazards -= 1
			if stats.player_turn == 1:
				playable_tiles[index] = Constants.BLOCK_STATE_PLAYER_1
			else:
				playable_tiles[index] = Constants.BLOCK_STATE_PLAYER_2
			
			return false
		
		Constants.BLOCK_STATE_0, \
		Constants.BLOCK_STATE_1, \
		Constants.BLOCK_STATE_2, \
		Constants.BLOCK_STATE_3, \
		Constants.BLOCK_STATE_4, \
		Constants.BLOCK_STATE_5, \
		Constants.BLOCK_STATE_6, \
		Constants.BLOCK_STATE_7, \
		Constants.BLOCK_STATE_8:
			playable_tiles[index] = tiles[index]
	
	if tiles[index] == Constants.BLOCK_STATE_0:
		if not is_left_edge(index): ripple_reveal(index - WIDTH - 1)
		ripple_reveal(index - WIDTH)
		if not is_right_edge(index): ripple_reveal(index - WIDTH + 1)
		
		if not is_left_edge(index): ripple_reveal(index - 1)
		if not is_right_edge(index): ripple_reveal(index + 1)
		
		if not is_left_edge(index): ripple_reveal(index + WIDTH - 1)
		ripple_reveal(index + WIDTH)
		if not is_right_edge(index): ripple_reveal(index + WIDTH + 1)
	
	return true


### HELPERS


func is_left_edge(index: int) -> bool:
	return index % WIDTH == 0


func is_right_edge(index: int) -> bool:
	return index % WIDTH == WIDTH - 1


func is_hazard(index: int) -> bool:
	if index < 0 or index >= SIZE:
		return false
	return tiles[index] == Constants.BLOCK_STATE_HAZARD


### SIGNALS


func _on_tile_hovered(tile: Node2D) -> void:
	$Cursor.global_position = tile.global_position


func _on_tile_actioned(index: int) -> void:
	if stats != null and stats.player_turn != Session.player_index:
		return
	
	rpc("reveal", index)
