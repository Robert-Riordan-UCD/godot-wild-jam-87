extends BaseController
class_name PlayerController

var active: bool = false
var rotation_tween: Tween
@onready var target_rotation: float = 0

func _process(_delta: float) -> void:
	if not tile_in_hand: return
	
	tile_in_hand.global_position = get_global_mouse_position()

func take_turn() -> void:
	active = true

func tile_placed() -> void:
	_end_turn()

func failed_to_place() -> void:
	tile_in_hand.shake()

func _end_turn(passed: bool=false) -> void:
	active = false
	tile_in_hand = null
	# NOTE: This is need to stop player 0 getting skipped for some reason
	#       Why only player 0????????
	await get_tree().process_frame
	end_turn.emit(passed)

func _input(event: InputEvent) -> void:
	if not active: return
	if event.is_action_pressed("pick_up_tile") and not tile_in_hand:
		select_tile.emit()
		target_rotation = 0
	elif event.is_action_pressed("place_tile") and tile_in_hand:
		place_tile.emit(tile_in_hand, get_global_mouse_position())
	if event.is_action_pressed("rotate_tile_cw") and tile_in_hand:
		if rotation_tween: rotation_tween.stop()
		rotation_tween = create_tween()
		target_rotation += 90
		rotation_tween.tween_property(tile_in_hand, "rotation_degrees", target_rotation, 0.1)
	if event.is_action_pressed("rotate_tile_acw") and tile_in_hand:
		if rotation_tween: rotation_tween.stop()
		rotation_tween = create_tween()
		target_rotation -= 90
		rotation_tween.tween_property(tile_in_hand, "rotation_degrees", target_rotation, 0.1)
	if event.is_action_pressed("drop_tile") and tile_in_hand:
		tile_in_hand.return_to_hand()
		tile_in_hand = null
		drop_tile.emit()
	elif event.is_action_pressed("remove_tile") and not tile_in_hand:
		remove_tile.emit(get_global_mouse_position())
	if event.is_action_pressed("pass"):
		if tile_in_hand:
			tile_in_hand.return_to_hand()
			tile_in_hand = null
		_end_turn(true)
