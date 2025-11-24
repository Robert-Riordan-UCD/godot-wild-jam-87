extends Node2D
class_name ScoreCalculator

const DOT = preload("res://dot.tscn")

var visited_over: Dictionary = {}
var visited_under: Dictionary = {}

func get_score() -> Dictionary[Hand, int]:
	for dot in get_tree().get_nodes_in_group("dot"):
		dot.queue_free()
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	
	visited_over = {}
	visited_under = {}
	var scores: Dictionary[Hand, int] = {}
	
	for edge in Globals.tile_map.get_open_edges():
		for over in [true, false]:
			var rope_score: Dictionary[Hand, int] = await draw_traverse(edge, over)
			for player in rope_score:
				scores[player] = scores.get(player, 0) + rope_score[player]
	
	for edge in Globals.tile_map.get_closed_edges():
		for over in [true, false]:
			var rope_score: Dictionary[Hand, int] = await draw_traverse(edge, over, true)
			for player in rope_score:
				scores[player] = scores.get(player, 0) + rope_score[player]
	
	return scores


func draw_traverse(edge: Vector2, over: bool, loop: bool=false) -> Dictionary[Hand, int]:
	var points := await _traverse_rope(edge, over)
	if points.size() == 0: return {}
	if loop: points.append(points[0])
		
	var line := Line2D.new()
	line.width = 5
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(line)
	
	var scores: Dictionary[Hand, int] = {}
	
	for p in points.size():
		if not p >= points.size() - 1:
			var player = Globals.tile_map._get_tile_owner(Vector2i((points[p] + points[p+1])/2))
			scores[player] = scores.get(player, 0) + 1
			player.add_score(1)
		line.add_point(Globals.tile_map.global_position + points[p]*Globals.TILE_SIZE*Globals.tile_scale)
		await get_tree().create_timer(0.1).timeout
	
	var tween: Tween = create_tween()
	tween.tween_property(line, "self_modulate:a", 0.1, 0.2)
	
	var best_score = -1
	var tie: bool = false
	for player in scores:
		if best_score == scores[player]:
			tie = true
		elif best_score < scores[player]:
			best_score = scores[player]
			tie = false
	
	if scores.size() > 1 and not tie:
		await get_tree().create_timer(0.2).timeout
		for player in scores:
			if scores[player] == best_score:
				scores[player] = scores.get(player, 0) + points.size()-1-best_score
				player.add_score(points.size()-1-best_score)
				player.shout("Dominant! +" + str(points.size()-1-best_score))
	
	if loop:
		await get_tree().create_timer(0.2).timeout
		for player in scores:
			scores[player] = scores.get(player, 0)*2
			player.mult_score(2)
			player.shout("Loop! x2!")
	
	await get_tree().create_timer(0.2).timeout
	
	for player in scores:
		player.move_rope_to_total_score()
	
	return scores


func _traverse_rope(starting_edge: Vector2, over: bool, depth: int = 0) -> Array[Vector2]:
	if over and starting_edge in visited_over: return []
	if not over and starting_edge in visited_under: return []
	var next_edges := Globals.tile_map.get_next_edges(starting_edge, not over)
	var path: Array[Vector2] = [starting_edge]
	if over: visited_over[starting_edge] = null
	if not over: visited_under[starting_edge] = null
		
	for i in next_edges.size():
		var edge := next_edges[i]
		var part_path := await _traverse_rope(edge, not over, depth+1)
		path = path + part_path
	return path


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
