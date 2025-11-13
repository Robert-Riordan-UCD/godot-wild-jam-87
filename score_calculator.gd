extends Node2D
class_name ScoreCalculator

const DOT = preload("res://dot.tscn")

var visited_over: Dictionary = {}
var visited_under: Dictionary = {}


func get_score() -> Dictionary[Hand, int]:
	for dot in get_tree().get_nodes_in_group("dot"):
		dot.queue_free()
	
	var open_edges := Globals.tile_map.get_open_edges()
	var next_edges = []
	visited_over = {}
	visited_under = {}
	print("OPEN EDGES: ", open_edges)
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	
	for edge in open_edges:
		var path := await _traverse_rope(edge, true)
		var line := Line2D.new()
		line.width = 5
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		add_child(line)
		for point in path:
			line.add_point(Globals.tile_map.global_position + point*Globals.TILE_SIZE*Globals.tile_scale)
		break
	
	# FIXME: Currently using to keep game running
	# Simple score system. Most tiles
	var scores := _get_player_tile_count()
	return scores


func _traverse_rope(starting_edge: Vector2, over: bool, depth: int = 0) -> Array[Vector2]:
	if over and starting_edge in visited_over: return []
	if not over and starting_edge in visited_under: return []
	#_add_dot(Globals.tile_map.global_position + starting_edge*Globals.TILE_SIZE*Globals.tile_scale, Color(depth/5.0, 1.0, 1.0), over)
	var next_edges := Globals.tile_map.get_next_edges(starting_edge, not over)
	var path: Array[Vector2] = [starting_edge]
	if over: visited_over[starting_edge] = null
	if not over: visited_under[starting_edge] = null
	
	for i in next_edges.size():
		var edge := next_edges[i]
		#await get_tree().create_timer(0.7).timeout
		var part_path := await _traverse_rope(edge, not over, depth+1)
		path = path + part_path
	return path


# FIXME: debug input to test score without completing game
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		get_score()


func _add_dot(pos: Vector2, color: Color = Color.WHITE, over: bool = true) -> void:
	var dot := DOT.instantiate()
	add_child(dot)
	dot.global_position = pos
	dot.self_modulate = color
	dot.scale /= 1.5
	if over: dot.position.x -= 5
	else: dot.position.x += 5


func _get_player_tile_count() -> Dictionary[Hand, int]:
	var count: Dictionary[Hand, int] = {}
	for player in Globals.tile_map.tile_owners:
		count[player] = Globals.tile_map.tile_owners[player].size()
	return count
