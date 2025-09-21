extends CanvasLayer
class_name PauseMenu

const MAIN_MENU = "res://menus/main_menu.tscn"

@onready var paused: bool = false
@onready var settings: CanvasLayer = $"../Settings"

func _ready() -> void:
	resume()

func pause() -> void:
	paused = true
	visible = true
	get_tree().paused = true

func resume() -> void:
	paused = false
	visible = false
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if paused: resume()
		else: pause()

func _on_resume_pressed() -> void:
	resume()

func _on_settings_pressed() -> void:
	visible = false
	settings.visible = true

func _on_main_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)
