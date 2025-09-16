extends BaseController
class_name PlayerController

var active: bool = false

func _process(_delta: float) -> void:
	if not tile_in_hand: return
	
	tile_in_hand.global_position = get_global_mouse_position() - (Globals.TILE_SIZE*scale).rotated(rotation)/2

func take_turn() -> void:
	active = true

func tile_placed() -> void:
	_end_turn()

func _end_turn() -> void:
	active = false
	tile_in_hand = null
	# NOTE: This is need to stop player 0 getting skipped for some reason
	#       Why only player 0????????
	await get_tree().process_frame
	end_turn.emit()

func _input(event: InputEvent) -> void:
	if not active: return
	if event.is_action_pressed("pick_up_tile") and not tile_in_hand:
		select_tile.emit()
	elif event.is_action_pressed("place_tile") and tile_in_hand:
		place_tile.emit(tile_in_hand, get_global_mouse_position())
	if event.is_action_pressed("rotate_tile") and tile_in_hand:
		tile_in_hand.rotation_degrees += 90
	if event.is_action_pressed("remove_tile"):
		_end_turn()
		remove_tile.emit(get_global_mouse_position())
