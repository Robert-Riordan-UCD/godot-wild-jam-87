extends TextureRect
class_name Tile

signal tile_clicked(tile: Tile)

const tile_C = preload("res://assets/c.svg")
const tile_T = preload("res://assets/t.svg")
const tile_X = preload("res://assets/x.svg")

@export_enum("C", "T", "X") var type: = 0

@onready var mouse_over: bool = false
@onready var selected: bool = false

func _ready() -> void:
	match type:
		0: texture = tile_C
		1: texture = tile_T
		2: texture = tile_X

func _process(_delta: float) -> void:
	if not selected: return
	
	global_position = get_global_mouse_position() - (Globals.TILE_SIZE*scale).rotated(rotation)/2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pick_up_tile"):
		if mouse_over and not selected:
			await get_tree().process_frame
			tile_clicked.emit(self)
			selected = true
			scale *= 0.3
	if event.is_action_pressed("rotate_tile"):
		if selected:
			rotation_degrees += 90
	if event.is_action_pressed("remove_tile"):
		selected = false

func remove() -> void:
	reparent(get_tree().root)
	queue_free()

func placed() -> void:
	remove()

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
