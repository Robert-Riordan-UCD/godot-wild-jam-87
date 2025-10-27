extends CanvasLayer
class_name ColourSelect

@onready var bottom: Hand = $"../GUI/Players/Bottom"

func _on_green_pressed() -> void:
	_set_colour(0)

func _on_red_pressed() -> void:
	_set_colour(1)

func _on_orange_light_pressed() -> void:
	_set_colour(2)

func _on_orange_dark_pressed() -> void:
	_set_colour(3)

func _set_colour(index: int) -> void:
	bottom.colour_index = index
	bottom._draw_tiles()
