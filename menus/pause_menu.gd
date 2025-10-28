extends CanvasLayer
class_name PauseMenu

const MAIN_MENU = "res://menus/main_menu.tscn"

@onready var help_menu: HelpMenu = $HelpMenu
@onready var paused: bool = false
@onready var settings: CanvasLayer = $"../Settings"
@onready var pausable: bool = false

func _ready() -> void:
	SceneTransition.change_scene_begin.connect(_on_scene_change_begin)
	SceneTransition.change_scene_end.connect(_on_scene_change_end)
	resume()

func pause() -> void:
	if not pausable: return
	paused = true
	visible = true
	get_tree().paused = true

func resume() -> void:
	paused = false
	visible = false
	help_menu.visible = false
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
	SceneTransition.change_scene(MAIN_MENU)

func _on_scene_change_begin() -> void:
	pausable = false

func _on_scene_change_end() -> void:
	pausable = true

func _on_help_pressed() -> void:
	visible = false
	help_menu.visible = true

func _on_help_menu_help_back() -> void:
	help_menu.visible = false
	visible = true
