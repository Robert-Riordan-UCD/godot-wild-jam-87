extends CanvasLayer
class_name HelpMenu

signal help_back

func _on_back_pressed() -> void:
	help_back.emit()
