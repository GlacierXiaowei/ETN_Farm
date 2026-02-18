extends NodeDataResource
class_name TileMapLayerDataResource

@export var tilemap_layer_used_cells: Array[Vector2i]
@export var terrain_set: int = 0
@export var terrain: int = 3

func _save_data(node : Node2D) -> void:
	super._save_data(node)
	
	var tilemap_layer: TileMapLayer = node as TileMapLayer
	var cell: Array[Vector2i] = tilemap_layer.get_used_cells()
	
	tilemap_layer_used_cells = cell
	
	# 检查所有格子，找到耕地（terrain=4）
	if cell.size() > 0:
		# 遍历所有格子，寻找terrain=4（耕地）
		var found_dirt = false
		for c in cell:
			var cell_data = tilemap_layer.get_cell_tile_data(c)
			if cell_data != null:
				if cell_data.terrain == 4:
					terrain = cell_data.terrain
					terrain_set = cell_data.terrain_set
					found_dirt = true
					break
				elif cell_data.terrain == 3:
					if not found_dirt:
						terrain = cell_data.terrain
						terrain_set = cell_data.terrain_set


func _load_data(window: Window) -> void:
	var scene_node = window.get_node_or_null(node_path)
	
	if scene_node!=null:
		var tilemap_layer: TileMapLayer = scene_node as TileMapLayer
		tilemap_layer.set_cells_terrain_connect(tilemap_layer_used_cells, terrain_set, terrain, true)
