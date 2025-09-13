extends HBoxContainer
class_name Hand

signal new_tile(tile: Tile)

const TILE = preload("res://tile.tscn")

@export_range(0, 10) var hand_size: int = 3

func _ready() -> void:
	for i in range(hand_size):
		_add_tile()

func update() -> void:
	for i in range(hand_size - get_child_count()):
		_add_tile()

func new_hand() -> void:
	for tile in get_children():
		tile.reparent(get_tree().root)
		tile.queue_free()
	update()

func return_to_hand(tile: Tile) -> void:
	if not tile: return
	tile.reparent(self)
	update()

func _add_tile() -> void:
	var tile: Tile = TILE.instantiate()
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
