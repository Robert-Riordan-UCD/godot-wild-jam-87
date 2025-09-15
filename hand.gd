extends BoxContainer
class_name Hand

signal new_tile(tile: Tile)

enum hand_types {
	RANDOM,
	IN_ORDER
}

const TILE = preload("res://tile.tscn")

@export_range(0, 10) var hand_size: int = 3
@export var hand_type: hand_types = hand_types.RANDOM
@export var location: Vector2i = Vector2i.DOWN

func _ready() -> void:
	update()

func update() -> void:
	match hand_type:
		hand_types.RANDOM:
			for i in range(hand_size - get_child_count()):
				_add_tile()
		hand_types.IN_ORDER:
			_clear_hand()
			for i in range(hand_size - get_child_count()):
				_add_tile(i)

func new_hand() -> void:
	_clear_hand()
	update()

func _clear_hand() -> void:
	for tile in get_children():
		tile.remove()

func return_to_hand(tile: Tile) -> void:
	if not tile: return
	tile.reparent(self)
	update()

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
