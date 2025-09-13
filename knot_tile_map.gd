extends TileMapLayer
class_name  KnotTileMap

enum TileTransform {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

"""
	Attempt to remove a tile
	Returns true if a tile is removed or false if not
"""
func remove_tile(global_pos: Vector2) -> bool:
	var map_position := local_to_map(to_local(global_pos))
	
	# Cell not occupied
	if get_cell_tile_data(map_position) == null: return false
	
	erase_cell(map_position)
	return true

"""
	Attempt to place a tile
	Returns true if the tile is places or false if not
"""
func place_tile(global_pos:Vector2, tile_in_hand: Tile, tile_rotation: float) -> bool:
	var map_position := local_to_map(to_local(global_pos))
	
	# Cell occupied
	if not get_cell_tile_data(map_position) == null: return false
	
	set_cell(map_position, _tile_to_id(tile_in_hand), Vector2i(0, 0))
	_set_rotation(map_position, _angle_to_transfrom(tile_rotation))
	
	return true

func _tile_to_id(tile: Tile) -> int:
	match tile.type:
		Globals.tile_types.C: return 1
		Globals.tile_types.T: return 2
		Globals.tile_types.X: return 3
		_: return -1

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
