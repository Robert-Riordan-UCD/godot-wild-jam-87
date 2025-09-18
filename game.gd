extends Node2D
class_name Game

@onready var board: TileMapLayer = $Board
@onready var knot_tile_map: KnotTileMap = $Board/KnotTileMap
@onready var players: Players = $GUI/Players

func _ready() -> void:
	_center_board()

func _center_board() -> void:
	board.global_position = get_viewport_rect().size/2 - Vector2(Globals.TILE_SIZE.x*knot_tile_map.board_size.x*board.scale.x, Globals.TILE_SIZE.y*knot_tile_map.board_size.y*board.scale.y)/2

func _reset() -> void:
	players.update()

func _on_place_tile(from: Hand, tile: Tile, pos: Vector2) -> void:
	var success: bool = knot_tile_map.place_tile(pos, tile, from)
	if success:
		from.tile_placed()
		tile.placed()
		_reset()
	else:
		from.failed_to_place()

func _on_remove_tile(pos: Vector2) -> void:
	knot_tile_map.remove_tile(pos)
