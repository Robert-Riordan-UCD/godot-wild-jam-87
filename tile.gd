extends TextureRect
class_name Tile

signal tile_clicked(tile: Tile)

@export_enum("C", "T", "X") var type: = 0
@export var colour_index: int = 0

@onready var mouse_over: bool = false
@onready var selected: bool = false

@onready var player = get_parent()

var tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	texture.region = Rect2(200*colour_index, 200*type, 200, 200)

func _process(_delta: float) -> void:
	if not selected: return
	
	global_position = get_global_mouse_position() - (Globals.TILE_SIZE*scale).rotated(rotation)/2

func try_select() -> bool:
	if mouse_over and not selected:
		z_index = 1000
		z_as_relative = false
		tile_clicked.emit(self)
		selected = true
		tween.stop()
		tween = create_tween()
		tween.tween_property(
			self, "scale", Vector2(Globals.tile_scale, Globals.tile_scale), 0.3
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		return true
	return false

func remove() -> void:
	reparent(get_tree().root)
	queue_free()

func placed() -> void:
	remove()

func return_to_hand() -> void:
	player._add_tile(type)
	remove()

func _on_mouse_entered() -> void:
	if selected: return
	mouse_over = true
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _on_mouse_exited() -> void:
	if selected: return
	mouse_over = false
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
