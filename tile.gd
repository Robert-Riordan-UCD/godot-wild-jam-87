extends Sprite2D
class_name Tile

signal tile_clicked(tile: Tile)

@export_enum("C", "T", "X") var type: = 0
@export var colour_index: int = 0

@onready var mouse_over: bool = false
@onready var selected: bool = false
@onready var player = get_parent()

var home_position: Vector2

var tween: Tween
var shake_tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	texture.region = Rect2(200*colour_index, 200*type, 200, 200)

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
	player.reset_tiles()
	remove()

func shake():
	material.set_shader_parameter("intensity", 45.0)
	if shake_tween: shake_tween.stop()
	shake_tween = create_tween()
	shake_tween.tween_property(material, "shader_parameter/intensity", 0.0, 0.5)

func _on_mouse_entered() -> void:
	if selected: return
	if player.controller is CPUComtrollerRandom: return
	mouse_over = true
	
	if tween: tween.stop()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "global_position:y", home_position.y-20, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _on_mouse_exited() -> void:
	if selected: return
	if player.controller is CPUComtrollerRandom: return
	mouse_over = false
	
	if tween: tween.stop()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "global_position:y", home_position.y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
