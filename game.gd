extends Node2D
class_name Game

@onready var tile_in_hand: Tile = null
@onready var tile_rotation: float = 0

@onready var knot_tile_map: TileMapLayer = $KnotTileMap
@onready var hand: Hand = $GUI/Hand

func _on_tile_clicked(tile_type: Tile) -> void:
	if tile_in_hand == null:
		tile_in_hand = tile_type

func _on_hand_new_tile(tile: Tile) -> void:
	tile.tile_clicked.connect(_on_tile_clicked)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_tile"):
		knot_tile_map.remove_tile(get_global_mouse_position())
		hand.return_to_hand(tile_in_hand)
		_reset()
	if event.is_action_pressed("rotate_tile"):
		tile_rotation += 90
	if event.is_action_pressed("place_tile"):
		if not tile_in_hand == null:
			var success: bool = knot_tile_map.place_tile(get_global_mouse_position(), tile_in_hand, tile_rotation)
			if success:
				tile_in_hand.placed()
				_reset()
				hand.new_hand()

func _reset() -> void:
	tile_in_hand = null
	hand.update()
	tile_rotation = 0
