extends TileMapLayer
class_name  KnotTileMap

enum TileTransform {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

# set to -1 for infinite
@export var board_size: Vector2i = Vector2i(-1, -1)
@export var just_for_art: bool = false

@export_category("Placement Rules")
@export var can_remove_tile: bool = false
@export var can_replace_tile: bool = false
@export var must_neighbour_own_tile: bool = true
@export var must_create_valid_placement: bool = true
@export var must_create_a_link: bool = true
@export var must_create_a_link_with_self: bool = true
#@export var can_neighbour_other_players: bool = false
#@export var must_not_link_to_other_players: bool = true

@onready var tile_owners: Dictionary[Hand, Array] = {}

func _ready() -> void:
	if not just_for_art:
		Globals.tile_map = self
	if not just_for_art and Globals.num_cpus + Globals.num_players > 0:
		clear()

"""
	Attempt to remove a tile
	Returns true if a tile is removed or false if not
"""
func remove_tile(global_pos: Vector2) -> bool:
	if not can_remove_tile: return false
	var map_position := local_to_map(to_local(global_pos))
	
	# Cell not occupied
	if get_cell_tile_data(map_position) == null: return false
	
	erase_cell(map_position)
	return true

"""
	Attempt to place a tile
	Returns true if the tile is places or false if not
"""
func place_tile(global_pos:Vector2, tile_in_hand: Tile, player: Hand=null) -> bool:
	var map_position := local_to_map(to_local(global_pos))
	var tile_rotation := tile_in_hand.rotation_degrees
	
	if not _can_place(map_position, tile_in_hand, tile_rotation, player): return false
	
	_set_cell(tile_in_hand, map_position, player)
	
	return true

func force_place_tile(tile: Tile, pos: Vector2i, player: Hand) -> void:
	_set_cell(tile, pos, player)

func _set_cell(tile: Tile, pos: Vector2i, player: Hand) -> void:
	set_cell(pos, 0, Vector2i(tile.colour_index, tile.type))
	_set_rotation(pos, _angle_to_transfrom(tile.rotation_degrees))
	tile_owners[player] = tile_owners.get(player, []) + [pos]

func _can_place(map_pos: Vector2i, tile: Tile, rot: float, player: Hand) -> bool:
	# On board
	if not _on_board(map_pos): return false
	
	# First tile
	if tile_owners.get(player, []).is_empty():
		for p in tile_owners:
			for t in tile_owners[p]:
				if t == map_pos: return false
		return true
	
	# Cell occupied
	if not can_replace_tile and not get_cell_tile_data(map_pos) == null: return false

	# No neighbours
	if must_neighbour_own_tile and _get_neighbors(map_pos, player).is_empty(): return false
	
	# Check placement
	if must_create_valid_placement and not _check_links_valid(map_pos, tile, rot): return false
	
	# Check at least one link
	if must_create_a_link and _count_links(map_pos, tile, rot) <= 0: return false
	
	# Check at least one link
	if must_create_a_link_with_self and _count_links(map_pos, tile, rot, player) <= 0: return false
	
	return true

"""
	Returns a set of all cells adjcent to the placed tiles
"""
func get_placeable_cells(player: Hand) -> Dictionary[Vector2i, Variant]:
	var cells: Dictionary[Vector2i, Variant] = {}
	
	if tile_owners.get(player, []).is_empty():
		for x in range(board_size.x):
			for y in range(board_size.y):
				cells[Vector2i(x, y)] = null
	
	var used_cells: Array
	if must_neighbour_own_tile:
		used_cells = tile_owners[player]
	else:
		used_cells = get_used_cells()
	
	for cell in used_cells:
		if must_neighbour_own_tile and not cell in tile_owners.get(player, []): continue
		for dir in Globals.directions:
			if get_cell_tile_data(cell+dir) == null and _on_board(cell+dir):
				cells[cell+dir] = null
	
	return cells

"""
	Returns a string with either 0, 1, or x (meaning don't care) for each side of the tile at the location
"""
func get_valid_tiles_at_location(location: Vector2i) -> String:
	if not get_cell_tile_data(location) == null:
		return ""
	
	var links := ""
	
	# North
	if get_cell_tile_data(location+Vector2i.UP):
		var dir := Vector2i.UP
		var id := get_cell_source_id(location+dir)
		var alt := get_cell_alternative_tile(location+dir)
		links += str(int(_get_links(_id_to_type(id), alt)[2]))
	else:
		links += "x"
	# East
	if get_cell_tile_data(location+Vector2i.RIGHT):
		var dir := Vector2i.RIGHT
		var id := get_cell_source_id(location+dir)
		var alt := get_cell_alternative_tile(location+dir)
		links += str(int(_get_links(_id_to_type(id), alt)[3]))
	else:
		links += "x"
	# South
	if get_cell_tile_data(location+Vector2i.DOWN):
		var dir := Vector2i.DOWN
		var id := get_cell_source_id(location+dir)
		var alt := get_cell_alternative_tile(location+dir)
		links += str(int(_get_links(_id_to_type(id), alt)[0]))
	else:
		links += "x"
	# West
	if get_cell_tile_data(location+Vector2i.LEFT):
		var dir := Vector2i.LEFT
		var id := get_cell_source_id(location+dir)
		var alt := get_cell_alternative_tile(location+dir)
		links += str(int(_get_links(_id_to_type(id), alt)[1]))
	else:
		links += "x"
	
	return links

func _on_board(map_position: Vector2i) -> bool:
	if board_size.x > -1 and (map_position.x < 0 or map_position.x >= board_size.x): return false
	if board_size.y > -1 and (map_position.y < 0 or map_position.y >= board_size.y): return false
	return true


func _count_links(map_pos: Vector2i, tile: Tile, rot: float, player: Hand=null) -> int:
	var count := 0
	var links := _get_links(tile.type, _angle_to_transfrom(rot))
	var neighbours: Array[Vector2i] = _get_neighbors(map_pos, player)
	
	for i in range(4):
		var dir := map_pos + Globals.directions[i]
		if dir-map_pos in neighbours:
			var atlas_coords := get_cell_atlas_coords(dir)
			var alt := get_cell_alternative_tile(dir)
	
			var valid: bool
			match Globals.directions[i]:
				Vector2i.UP: valid = links[0] and _get_links(atlas_coords.y, alt)[2]
				Vector2i.RIGHT: valid = links[1] and _get_links(atlas_coords.y, alt)[3]
				Vector2i.DOWN: valid = links[2] and _get_links(atlas_coords.y, alt)[0]
				Vector2i.LEFT: valid = links[3] and _get_links(atlas_coords.y, alt)[1]
			count += int(valid)
	
	return count

func _check_links_valid(map_pos: Vector2i, tile: Tile, rot: float) -> bool:
	var links := _get_links(tile.type, _angle_to_transfrom(rot))
	
	for i in range(4):
		var dir := map_pos + Globals.directions[i]
		if get_cell_tile_data(dir):
			var atlas_coords := get_cell_atlas_coords(dir)
			var alt := get_cell_alternative_tile(dir)
	
			var valid: bool
			match Globals.directions[i]:
				Vector2i.UP: valid = links[0] == _get_links(atlas_coords.y, alt)[2]
				Vector2i.RIGHT: valid = links[1] == _get_links(atlas_coords.y, alt)[3]
				Vector2i.DOWN: valid = links[2] == _get_links(atlas_coords.y, alt)[0]
				Vector2i.LEFT: valid = links[3] == _get_links(atlas_coords.y, alt)[1]
			if not valid: return false
	
	return true

"""
	Returns an array of booleans [north, east, south, west] that is true is a link is needed and false if a link is blocked
"""
func _get_links(tile_type: int, tile_transform: TileTransform) -> Array[bool]:
	var links: Array[bool]
	match tile_type:
		0: links = [false, true, true, false]
		1: links = [false, true, true, true]
		2: return [true, true, true, true]
	
	match tile_transform:
		TileTransform.ROTATE_0: pass
		TileTransform.ROTATE_90: links = links.slice(3, 4) + links.slice(0, 3)
		TileTransform.ROTATE_180: links = links.slice(2, 4) + links.slice(0, 2)
		TileTransform.ROTATE_270: links = links.slice(1, 4) + links.slice(0, 1)
	
	return links

func _get_neighbors(map_pos: Vector2i, player: Hand=null) -> Array:
	var neighbors: Array[Vector2i] = []
	
	for d in Globals.directions:
		if not get_cell_tile_data(map_pos + d) == null:
			if player == null:
				neighbors.append(d)
			else:
				if map_pos + d in tile_owners[player]:
					neighbors.append(d)
	
	return neighbors

func _tile_to_id(tile: Tile) -> int:
	match tile.type:
		Globals.tile_types.C: return 1
		Globals.tile_types.T: return 2
		Globals.tile_types.X: return 3
		_: return -1

func _id_to_type(id: int) -> Globals.tile_types:
	match id:
		1: return Globals.tile_types.C
		2: return Globals.tile_types.T
		3: return Globals.tile_types.X
		_: return Globals.tile_types.ERROR

func _angle_to_transfrom(angle: float) -> TileTransform:
	angle = int(angle)%360
	match angle:
		0.0: return TileTransform.ROTATE_0
		90.0: return TileTransform.ROTATE_90
		180.0: return TileTransform.ROTATE_180
		270.0: return TileTransform.ROTATE_270
		_: return TileTransform.ROTATE_0

func _set_rotation(map_pos: Vector2i, rot: TileTransform) -> void:
	var alternate_id = get_cell_alternative_tile(map_pos)
	set_cell(map_pos, get_cell_source_id(map_pos), get_cell_atlas_coords(map_pos), alternate_id | rot)
