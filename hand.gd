extends Control
class_name Hand

signal new_tile(tile: Tile)
signal place_tile(from: Hand, tile: Tile, pos: Vector2)
signal turn_finished
signal remove_tile(pos: Vector2)

enum hand_types {
	RANDOM,
	IN_ORDER
}

const TILE = preload("res://tile.tscn")

@export_range(0, 10) var hand_size: int = 3
@export var hand_type: hand_types = hand_types.RANDOM
@export var location: Vector2i = Vector2i.DOWN
@export var controller_type: Globals.controller_type = Globals.controller_type.PLAYER

const PLAYER_CONTROLLER = preload("res://controllers/player_controller.tscn")
var controller: BaseController

func _ready() -> void:
	_set_controller()
	update()

func update() -> void:
	var tiles_needed: int = hand_size
	for child in get_children():
		if child is Tile:
			tiles_needed -= 1
		if child is BaseController:
			child.reset()
	
	match hand_type:
		hand_types.RANDOM:
			for i in range(tiles_needed):
				_add_tile()
		hand_types.IN_ORDER:
			await _clear_hand()
			for i in range(hand_size):
				_add_tile(i)
				

func take_turn() -> void:
	visible = true
	controller.take_turn()
	await controller.end_turn
	visible = false
	turn_finished.emit()

func new_hand() -> void:
	_clear_hand()
	update()

func return_to_hand(tile: Tile) -> void:
	if not tile: return
	tile.reparent(self)
	update()

func tile_placed():
	controller.tile_placed()

func _set_controller() -> void:
	controller = PLAYER_CONTROLLER.instantiate()
	add_child(controller)
	controller.select_tile.connect(_select_tile)
	controller.place_tile.connect(_place_tile)
	controller.remove_tile.connect(_remove_tile)
	controller.drop_tile.connect(_drop_tile)

func _clear_hand() -> void:
	for tile in get_children():
		if tile is Tile:
			tile.remove()
	await get_tree().process_frame

func _add_tile(t: int = -1) -> void:
	var tile: Tile = TILE.instantiate()
	if t >= 0:
		tile.type = t
	else:
		tile.type = randi_range(0, 2)
	add_child(tile)
	tile.scale = tile.scale/2
	new_tile.emit(tile)
	tile.tile_clicked.connect(_tile_clicked)

func _tile_clicked(tile: Tile) -> void:
	await get_tree().process_frame
	if not tile.selected: 
		return
	tile.reparent(get_tree().root)

func _select_tile() -> void:
	for tile in get_children():
		if tile is Tile:
			if tile.try_select():
				controller.tile_in_hand = tile
				return

func _place_tile(tile: Tile, global_pos: Vector2) -> void:
	place_tile.emit(self, tile, global_pos)

func _remove_tile(pos: Vector2) -> void:
	remove_tile.emit(pos)

func _drop_tile() -> void:
	visible = false
	await  get_tree().process_frame
	visible = true
