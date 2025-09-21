extends BaseController
class_name CPUComtrollerRandom

@export var max_attempts: int = 100
@onready var attempts: int = 0

"""
	1. Get list of valid locations
	2. Pick a random locations
	#TODO 3. Get list of valid tiles for that place
	#TODO 4. Select tile from hand that is in list
		#TODO a. Return to 2 if none
	5. Rotate tile
	6. Place tile
"""
func take_turn() -> void:
	attempts = 0
	_try_turn()

func _try_turn() -> void:
	if attempts == 0 and Globals.num_players > 0:
		await get_tree().create_timer(1).timeout
	# Not sure why this script isn't respecting process_mode
	while get_tree().paused: await get_tree().create_timer(0.2).timeout

	await get_tree().process_frame
	var open_locations := _get_valid_tile_locations()
	if open_locations.is_empty():
		end_turn.emit(false)
		hand.queue_free()
		queue_free()
		return
	var selected_location: Vector2i = open_locations.keys().pick_random()
	var selected_tile: Tile = hand.get_tiles().pick_random()
	selected_tile.rotation_degrees += randi_range(0, 3)*90
	place_tile.emit(selected_tile, Globals.tile_map.to_global(Globals.tile_map.map_to_local(selected_location)))
	#print(selected_location, selected_tile, selected_tile.rotation_degrees)
	#var valid_tiles = _get_valid_tiles_at_location(selected_location)
	#print(selected_location, valid_tiles)
	await get_tree().create_timer(2).timeout

func failed_to_place() -> void:
	attempts += 1
	if attempts == max_attempts:
		attempts = 0
		end_turn.emit(true)
	else:
		_try_turn()

func _get_valid_tiles_at_location(pos: Vector2i) -> String:
	return Globals.tile_map.get_valid_tiles_at_location(pos)

func _get_valid_tile_locations() -> Dictionary[Vector2i, Variant]:
	return Globals.tile_map.get_placeable_cells(hand)
