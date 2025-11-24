extends Node
class_name CreativeSetup

@onready var players: Players = $"../GUI/Players"
@onready var knot_tile_map: KnotTileMap = $"../Board/KnotTileMap"
@onready var tutorial: CanvasLayer = $"../Tutorial"

func _ready() -> void:
	tutorial.queue_free()
	players.game_over.disconnect(get_parent()._on_game_over)
	
	for i in range(1, players.get_child_count()):
		players.get_child(i).queue_free()
	
	knot_tile_map.clear()
	knot_tile_map.tile_owners.clear()
