extends Node2D
class_name ScoreCalculator

const DOT = preload("res://dot.tscn")

var tile_map: KnotTileMap

# [over][direction in] -> direction out
var c_directions: Array[Array] = [
	[-1, 2, 1, -1],# Under
	[-1, 2, 1, -1] # Over
]

var t_directions: Array[Array] = [
	[-1, 3, 1, 2],# Under
	[-1, 2, 3, 1] # Over
]

var x_directions: Array[Array] = [
	[3, 0, 1, 2],# Under
	[1, 2, 3, 0] # Over
]

func _process(delta: float) -> void:
	return
	for child in get_children():
		child.queue_free()
	get_score()

func get_score() -> Array[int]:
	tile_map = Globals.tile_map
	
	var traversed_over: Array[Array] = []
	var traversed_under: Array[Array] = []
	for x in range(tile_map.board_size.x+1):
		traversed_over.append([])
		traversed_under.append([])
		for y in range(tile_map.board_size.y+1):
			traversed_over[x].append(false)
			traversed_under[x].append(false)
	
	#print(traversed_over)
	
	var open_edges := _get_open_edges()
	#print(open_edges)
	
	for edge in open_edges:
		# Find direction
		if edge.x == int(edge.x): # Edge is on the left or right of tile
			if tile_map.get_cell_tile_data(edge): # Edge is on left
				var score_over = _traverse(edge, 3, true)
				#var score_under = _traverse(edge, 3, false)
			else: # Edge is on right
				var score_over = _traverse(edge, 1, true)
				#var score_under = _traverse(edge, 1, false)
		else: # Edge is on the top or bottom of tile
			if tile_map.get_cell_tile_data(edge): # Edge is on top
				var score_over = _traverse(edge, 0, true)
				#var score_under = _traverse(edge, 0, false)
			else: # Edge is on bottom
				var score_over = _traverse(edge, 2, true)
				#var score_under = _traverse(edge, 2, false)
		
		#var over = _traverse(edge, true)
		#var under = _traverse(edge, false)
	return []

func _traverse(starting_edge: Vector2, coming_from_dir: int, over: bool) -> Array:
	var lengths: Array[int] = [0, 0, 0, 0]
	var tile: Vector2i
	match coming_from_dir:
		0: tile = Vector2i(starting_edge)
		1: tile = Vector2i(starting_edge)-Vector2i(1, 0)
		2: tile = Vector2i(starting_edge)-Vector2i(0, 1)
		3: tile = Vector2i(starting_edge)

	var tile_type: int = tile_map.get_cell_atlas_coords(tile).y
	var transform = tile_map.get_cell_alternative_tile(Vector2i(tile))
	var rot: int = 0
	
	match transform:
		tile_map.TileTransform.ROTATE_0: rot = 0
		tile_map.TileTransform.ROTATE_90: rot = 1
		tile_map.TileTransform.ROTATE_180: rot = 2
		tile_map.TileTransform.ROTATE_270: rot = 3
	
	var dirs: Array
	match tile_type:
		0: dirs = c_directions[int(over)]
		1: dirs = t_directions[int(over)]
		2: dirs = x_directions[int(over)]
	
	var start_dot := DOT.instantiate()
	var gp := (Globals.TILE_SIZE * starting_edge)*0.3 + tile_map.global_position
	add_child(start_dot)
	start_dot.global_position = gp
	
	var next_dot := DOT.instantiate()
	var next_dir: int = (dirs[(coming_from_dir-rot+4)%4]+rot)%4
	# [from][next]
	var from_edge_to_edge: Array[Array] = [
		[Vector2.ZERO, Vector2(0.5, 0.5), Vector2(0, 1), Vector2(-0.5, 0.5)],
		[Vector2(-0.5, -0.5), Vector2.ZERO, Vector2(-1.25, 0), Vector2(-0.5, 0.5)],
		[Vector2(0, -1), Vector2(0.5, -0.5), Vector2.ZERO, Vector2(-0.5, -0.5)],
		[Vector2(0.5, -0.5), Vector2(1, 0), Vector2(0.5, 0.5), Vector2.ZERO],
	]
	var next_gp: Vector2 = gp + from_edge_to_edge[coming_from_dir][next_dir]*Globals.TILE_SIZE*0.3
	add_child(next_dot)
	next_dot.self_modulate = Color(0.5, 0.5, 0.0)
	next_dot.global_position = next_gp
	
	print("From: ", starting_edge, ', From dir: ', coming_from_dir, ', Over: ', int(over), ', Rot: ', rot)
	print("Tile pos: ", tile, ", Type: ", tile_type)
	print("Next dir: ", next_dir)
	print("  dirs: ", dirs)
	print("  dirs[from+rot]: ", dirs[(coming_from_dir-rot+4)%4])
	print()
	return []

"""
	Returns a array of vectors, each locatiing the center if an open edge
	(0, 0) is the top left corner
	All edges should be offset by 0.5 on the axis the edge lies on
	e.g. the right hand edge of the tile at (0, 0) will be at (1, 0.5)
"""
func _get_open_edges() -> Array[Vector2]:
	var open_edges: Array[Vector2] = []
	for tile in tile_map.get_used_cells():
		var links = tile_map._get_links(tile_map.get_cell_atlas_coords(tile).y, tile_map.get_cell_alternative_tile(tile))
		for d in Globals.directions:
			if tile_map.get_cell_tile_data(tile+d): continue
			# Check for open edge if there is no neighbour
			match d:
				Vector2i.UP: if links[0]: open_edges.append(Vector2(tile)+Vector2(0.5, 0))
				Vector2i.RIGHT: if links[1]: open_edges.append(Vector2(tile)+Vector2(1, 0.5))
				Vector2i.DOWN: if links[2]: open_edges.append(Vector2(tile)+Vector2(0.5, 1))
				Vector2i.LEFT: if links[3]: open_edges.append(Vector2(tile)+Vector2(0, 0.5))
	return open_edges
	
	##each tile stores where to go if you arrive on a side from over or under
	##[<OVER>, <UNDER>]
	##X = [[r, l],[d, u],[l ,r],[u, d]]
	##T = [[-, -],[d, l],[l ,r],[r, d]]
	##C = [[-, -],[d, d],[r, r],[-, -]]
##
	##Get all open edges
		##for each open edge traverse twice
			##if traversed
				##skip
			##once starting over
			##once starting under
			##toggle over/under on each step
			##mark each edge passed as traverse over or under 
			##track colours
##
	##Get untraversed edges
		##Pick a random edge a repeat proc above
		##rapeat until all edges are traversed
#
	#return []
