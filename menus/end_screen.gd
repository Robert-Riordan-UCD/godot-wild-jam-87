extends CanvasLayer

const MAIN_MENU = "res://menus/main_menu.tscn"
@onready var label: Label = $VBoxContainer/Label

func game_over(win_text: String="Player ¯\\_(ツ)_/¯ wins!") -> void:
	label.text = win_text
	visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene(MAIN_MENU)
