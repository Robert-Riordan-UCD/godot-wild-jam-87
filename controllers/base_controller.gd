extends Node2D
class_name BaseController

@warning_ignore("unused_signal")
signal select_tile()
@warning_ignore("unused_signal")
signal place_tile(tile: Tile, global_pos: Vector2)
@warning_ignore("unused_signal")
signal remove_tile(gloabl_pos: Vector2)
@warning_ignore("unused_signal")
signal drop_tile
signal end_turn(passed: bool)

var hand: Hand
var tile_in_hand: Tile

func take_turn() -> void:
	await get_tree().process_frame

func reset() -> void:
	if tile_in_hand:
		tile_in_hand.remove()
	tile_in_hand = null

func tile_placed() -> void:
	end_turn.emit(false)

func failed_to_place() -> void:
	pass
