extends CanvasLayer
class_name Settings

@onready var pause_menu: PauseMenu = $"../PauseMenu"
@onready var music: HSlider = $VBoxContainer/VBoxContainer/GridContainer/HSlider
@onready var sound: HSlider = $VBoxContainer/VBoxContainer/GridContainer/HSlider2

func _ready() -> void:
	music.value = Audio.volume_db
	sound.value = Globals.sound_fx_db

func _on_back_pressed() -> void:
	visible = false
	pause_menu.visible = true

func _on_h_slider_value_changed(value: float) -> void:
	Audio.volume_db = value
	Audio.volume_changed.emit()

func _effects_value_changed(value: float) -> void:
	Globals.sound_fx_db = value

func _on_h_slider_3_value_changed(value: float) -> void:
	Audio.bird_volume_db = value
	Audio.birds_changed.emit()
