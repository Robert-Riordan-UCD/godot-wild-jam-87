extends CanvasLayer

const MAIN_MENU = "res://menus/main_menu.tscn"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
