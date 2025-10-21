extends CanvasLayer

@onready var option_button: OptionButton = $VBoxContainer/Preset/OptionButton

@onready var decrease_width: Button = $"VBoxContainer/Board width/DecreaseWidth"
@onready var width: Label = $"VBoxContainer/Board width/Width"
@onready var increase_width: Button = $"VBoxContainer/Board width/IncreaseWidth"
@onready var decrease_height: Button = $"VBoxContainer/Board height/DecreaseHeight"
@onready var height: Label = $"VBoxContainer/Board height/Height"
@onready var increase_height: Button = $"VBoxContainer/Board height/IncreaseHeight"

@onready var removable_tiles: CheckButton = $VBoxContainer/RemovableTiles
@onready var must_neighbour: CheckButton = $VBoxContainer/MustNeighbour
@onready var must_link: CheckButton = $VBoxContainer/MustLink
@onready var edge_valid: CheckButton = $VBoxContainer/EdgeValid

@onready var play: Button = $VBoxContainer/Buttons/Play
@onready var main_menu: Button = $VBoxContainer/Buttons/MainMenu

const CREATIVE = "res://modes/creative.tscn"
const MAIN_MENU = "res://menus/main_menu.tscn"


func _set_custom() -> void:
	option_button.selected = 2


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: # Creative
			width.text = str(9)
			height.text = str(9)
			removable_tiles.button_pressed = true
			must_neighbour.button_pressed = false
			must_link.button_pressed = false
			edge_valid.button_pressed = false
		1: # Competative
			width.text = str(9)
			height.text = str(9)
			removable_tiles.button_pressed = false
			must_neighbour.button_pressed = true
			must_link.button_pressed = true
			edge_valid.button_pressed = true
		2: # Custom
			pass


func _on_decrease_width_pressed() -> void:
	width.text = str(max(int(width.text)-1, 1))
	_set_custom()


func _on_increase_width_pressed() -> void:
	width.text = str(int(width.text)+1)
	_set_custom()


func _on_decrease_height_pressed() -> void:
	height.text = str(max(int(height.text)-1, 1))
	_set_custom()


func _on_increase_height_pressed() -> void:
	height.text = str(int(height.text)+1)
	_set_custom()


func _on_removable_tiles_toggled(_toggled_on: bool) -> void:
	_set_custom()


func _on_must_neighbour_toggled(_toggled_on: bool) -> void:
	if not _toggled_on:
		must_link.button_pressed = false
	_set_custom()


func _on_must_link_toggled(_toggled_on: bool) -> void:
	if _toggled_on:
		must_neighbour.button_pressed = true
	_set_custom()


func _on_edge_valid_toggled(_toggled_on: bool) -> void:
	_set_custom()


func _on_play_pressed() -> void:
	Globals.num_players = 1
	Globals.num_cpus = 0
	
	Globals.custom_game = true
	
	Globals.board_width = int(width.text)
	Globals.board_height = int(height.text)
	Globals.can_remove_tile = removable_tiles.button_pressed
	Globals.can_replace_tile = removable_tiles.button_pressed
	Globals.must_neighbour_own_tile = must_neighbour.button_pressed
	Globals.must_create_a_link = must_link.button_pressed
	Globals.must_create_a_link_with_self = false
	Globals.must_create_valid_placement = edge_valid.button_pressed
	
	SceneTransition.change_scene(CREATIVE)


func _on_main_menu_pressed() -> void:
	SceneTransition.change_scene(MAIN_MENU)
