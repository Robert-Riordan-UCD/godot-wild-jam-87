extends Node2D
class_name Game

@onready var tile_in_hand: Tile = null
@onready var tile_rotation: float = 0

@onready var board: TileMapLayer = $Board
@onready var knot_tile_map: TileMapLayer = $Board/KnotTileMap
@onready var players: Players = $GUI/Players

func _ready() -> void:
	_center_board()

func _center_board() -> void:
	board.global_position = get_viewport_rect().size/2 - Vector2(Globals.TILE_SIZE.x*knot_tile_map.board_size.x*board.scale.x, Globals.TILE_SIZE.y*knot_tile_map.board_size.y*board.scale.y)/2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_tile"):
		knot_tile_map.remove_tile(get_global_mouse_position())
		if tile_in_hand:
			tile_in_hand.return_to_hand()
		_reset()

func _reset() -> void:
	players.update()
	tile_rotation = 0

func _on_place_tile(from: Hand, tile: Tile, pos: Vector2) -> void:
	var success: bool = knot_tile_map.place_tile(pos, tile)
	if success:
		from.tile_placed()
		tile.placed()
		_reset()
