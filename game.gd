extends Node2D
class_name Game

@onready var board: TileMapLayer = $Board
@onready var knot_tile_map: KnotTileMap = $Board/KnotTileMap
@onready var players: Players = $GUI/Players
@onready var end_screen: CanvasLayer = $EndScreen
@onready var score_calculator: ScoreCalculator = $ScoreCalculator
@onready var tiles: Node2D = $Sound/Tiles

func _ready() -> void:
	_setup_board()

func _setup_board() -> void:
	board.scale = Vector2(Globals.tile_scale, Globals.tile_scale)
	board.global_position = get_viewport_rect().size/2 - Vector2(Globals.TILE_SIZE.x*knot_tile_map.board_size.x*board.scale.x, Globals.TILE_SIZE.y*knot_tile_map.board_size.y*board.scale.y)/2
	var board_size := knot_tile_map.board_size
	for x in range(board_size.x):
		for y in range(board_size.y):
			board.set_cell(Vector2i(x, y), 1, Vector2i(0, 2))
	for x in range(board_size.x):
		board.set_cell(Vector2i(x, -1), 1, Vector2i(0, 1))
		board.set_cell(Vector2i(x, board_size.y), 1, Vector2i(0, 1), TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V)
	for y in range(board_size.y):
		board.set_cell(Vector2i(-1, y), 1, Vector2i(0, 1), TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V)
		board.set_cell(Vector2i(board_size.x, y), 1, Vector2i(0, 1), TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H)
	board.set_cell(Vector2i(-1, -1), 1, Vector2i(0, 0))
	board.set_cell(Vector2i(board_size.x, -1), 1, Vector2i(0, 0), TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H)
	board.set_cell(Vector2i(board_size.x, board_size.y), 1, Vector2i(0, 0), TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V)
	board.set_cell(Vector2i(-1, board_size.y), 1, Vector2i(0, 0), TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V)

func _on_place_tile(from: Hand, tile: Tile, pos: Vector2) -> void:
	var success: bool = knot_tile_map.place_tile(pos, tile, from)
	if success:
		from.tile_placed()
		tile.placed()
		_play_tile_places_sound()
	else:
		from.failed_to_place()

func _on_remove_tile(pos: Vector2) -> void:
	knot_tile_map.remove_tile(pos)
	_play_tile_places_sound()

func _on_game_over() -> void:
	var scores := score_calculator.get_score()
	var winner: Hand
	var winner_score: int = -1
	var tie: bool = false
	for player in scores:
		if scores[player] > winner_score:
			winner = player
			winner_score = scores[player]
			tie = false
		elif scores[player] == winner_score:
			tie = true
	print(scores)
	print(winner, winner_score)
	players.queue_free()
	if tie:
		end_screen.game_over("It's a tie!")
	else:
		end_screen.game_over(winner.name + " wins!")

func _play_tile_places_sound() -> void:
	for tile in tiles.get_children():
		tile.volume_db = Globals.sound_fx_db
	tiles.get_child(randi_range(0, tiles.get_child_count()-1)).play()
