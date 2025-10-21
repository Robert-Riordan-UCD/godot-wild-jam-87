extends Node
class_name CreativeSetup

@onready var players: Players = $"../GUI/Players"
@onready var knot_tile_map: KnotTileMap = $"../Board/KnotTileMap"

func _ready() -> void:
	for i in range(1, players.get_child_count()):
		players.get_child(i).queue_free()
	
	knot_tile_map.clear()
	knot_tile_map.tile_owners.clear()
