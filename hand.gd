extends Control
class_name Hand

signal new_tile(tile: Tile)
signal place_tile(from: Hand, tile: Tile, pos: Vector2)
signal turn_finished(passed: bool)
signal remove_tile(pos: Vector2)

enum hand_types {
	RANDOM,
	IN_ORDER
}

const TILE = preload("res://tile.tscn")
const ALERT = preload("res://alert.tscn")
const TILE_DRAW_TIME = 0.3

@export_range(0, 10) var hand_size: int = 3
@export var hand_type: hand_types = hand_types.RANDOM
@export var location: Vector2i = Vector2i.DOWN
@export var controller_type: Globals.controller_type = Globals.controller_type.PLAYER
@export var colour_index: int = 0

@export var alert_pos: Vector2 = Vector2(540, 540)

@export var draw_from_position: Vector2 = Vector2.ZERO
@export var hand_center: Vector2 = Vector2(1080, 1080)/2
@export var discard_to_position: Vector2 = Vector2(1080, 1080)

const PLAYER_CONTROLLER = preload("res://controllers/player_controller.tscn")
const CPU_CONTROLLER_RANDOM = preload("res://controllers/cpu_controller_random.tscn")
var controller: BaseController

func _ready() -> void:
	_set_controller()
	#update()

func setup() -> void:
	if not Globals.tile_map.is_node_ready():
		await Globals.tile_map.ready
	var t: Tile = load("res://tile.tscn").instantiate()
	t.type = 1
	var board_size: Vector2i = Globals.tile_map.board_size
	
	match location:
		Vector2i.DOWN:
			t.rotation_degrees = 180
			Globals.tile_map.force_place_tile(t, Vector2i(int(board_size.x/2.0), board_size.y-1), self)
		Vector2i.RIGHT:
			t.rotation_degrees = 90
			t.colour_index = 3
			Globals.tile_map.force_place_tile(t, Vector2i(board_size.x-1, int(board_size.y/2.0)), self)
		Vector2i.UP:
			t.colour_index = 1
			Globals.tile_map.force_place_tile(t, Vector2i(int(board_size.x/2.0), 0), self)
		Vector2i.LEFT:
			t.rotation_degrees = 270
			t.colour_index = 2
			Globals.tile_map.force_place_tile(t, Vector2i(0, int(board_size.y/2.0)), self)

#func update() -> void:
	#var tiles_needed: int = hand_size
	#for child in get_children():
		#if child is Tile:
			#tiles_needed -= 1
		#if child is BaseController:
			#child.reset()
	#
	#match hand_type:
		#hand_types.RANDOM:
			#for i in range(tiles_needed):
				#_add_tile()
		#hand_types.IN_ORDER:
			#await _clear_hand()
			#for i in range(hand_size):
				#_add_tile(i)

func draw_new_hand(random:bool = false) -> void:
	await _clear_hand()
	for i in range(hand_size):
		if random: _add_tile()
		else:      _add_tile(i)
	#await get_tree().process_frame

func take_turn() -> void:
	await _draw_tiles()
	controller.take_turn()

func new_hand() -> void:
	_clear_hand()
	#update()

func return_to_hand(tile: Tile) -> void:
	if not tile: return
	tile.reparent(self)
	#update()

func tile_placed():
	controller.tile_placed()

func set_controller(type: Globals.controller_type) -> void:
	for child in get_children():
		if child is BaseController:
			child.queue_free()
	controller_type = type
	_set_controller()

func get_tiles() -> Array[Tile]:
	var tiles: Array[Tile] = []
	for child in get_children():
		if child is Tile:
			tiles.append(child)
	return tiles

func failed_to_place() -> void:
	controller.failed_to_place()

func _set_controller() -> void:
	match controller_type:
		Globals.controller_type.PLAYER: controller = PLAYER_CONTROLLER.instantiate()
		Globals.controller_type.CPU_RANDOM: controller = CPU_CONTROLLER_RANDOM.instantiate()
	add_child(controller)
	controller.select_tile.connect(_select_tile)
	controller.place_tile.connect(_place_tile)
	controller.remove_tile.connect(_remove_tile)
	controller.drop_tile.connect(_drop_tile)
	controller.end_turn.connect(_end_turn)
	controller.hand = self

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
	tile.colour_index = colour_index
	add_child(tile)
	tile.scale = tile.scale/2
	tile.global_position = draw_from_position
	print(tile.global_position)
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
	#visible = false
	await get_tree().process_frame
	#visible = true

func _end_turn(passed: bool) -> void:
	await _discard_tiles()
	await get_tree().create_timer(0.5).timeout
	new_hand()
	turn_finished.emit(passed)
	if passed:
		_alert("Passed", alert_pos, 1.0)

func _draw_tiles() -> void:
	#visible = true
	#update()
	match hand_type:
		hand_types.RANDOM:
			await draw_new_hand(true)
		hand_types.IN_ORDER:
			await draw_new_hand()
	
	for tile in get_tiles():
		print(tile.global_position)
		#tile.global_position = draw_from_position
	
	for position_in_hand in hand_size:
		var tile: Tile = get_tiles()[position_in_hand]
		var tween: Tween = create_tween()
		var end_position := Vector2.ZERO
		match location:
			Vector2i.DOWN:
				end_position = hand_center+Globals.TILE_SIZE*Vector2(-hand_size/2.0+position_in_hand, -1)
			Vector2i.UP:
				end_position = hand_center+Globals.TILE_SIZE*(Vector2(-hand_size/2.0+position_in_hand, 0))
			Vector2i.LEFT:
				end_position = hand_center+Globals.TILE_SIZE*(Vector2(0, -hand_size/2.0+position_in_hand))
			Vector2i.RIGHT:
				end_position = hand_center+Globals.TILE_SIZE*(Vector2(-1, -hand_size/2.0+position_in_hand))
		tween.tween_property(
			tile,
			"global_position",
			end_position,
			TILE_DRAW_TIME
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.1*position_in_hand)
	await get_tree().create_timer(0.3).timeout

func _discard_tiles() -> void:
	for i in get_tiles().size():
		var tile: Tile = get_tiles()[i]
		var tween: Tween = create_tween()
		tween.tween_property(tile, "global_position", discard_to_position, TILE_DRAW_TIME).set_delay(0.1*i)
	await get_tree().create_timer(0.3).timeout
	#visible = false

func _alert(text: String, pos: Vector2, duration: float) -> void:
	var new_alert: Alert = ALERT.instantiate()
	get_tree().root.add_child(new_alert)
	new_alert.alert(text, pos, duration)
