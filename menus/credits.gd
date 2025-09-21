extends CanvasLayer

const MAIN_MENU = "res://menus/main_menu.tscn"

func _on_button_pressed() -> void:
	SceneTransition.change_scene(MAIN_MENU, 1.0)
