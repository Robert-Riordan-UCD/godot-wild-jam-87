extends CanvasLayer
class_name ColourSelect

@onready var bottom: Hand = $"../GUI/Players/Bottom"

func _on_green_pressed() -> void:
	bottom.colour_index = 0
	bottom.update()

func _on_red_pressed() -> void:
	bottom.colour_index = 1
	bottom.update()

func _on_orange_light_pressed() -> void:
	bottom.colour_index = 2
	bottom.update()

func _on_orange_dark_pressed() -> void:
	bottom.colour_index = 3
	bottom.update()
