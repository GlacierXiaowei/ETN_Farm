extends Node2D

## 地图边界碰撞生成器
## 功能：根据可行走区域自动生成碰撞边界，防止玩家走出安全区域
## 支持：多层检测、内外边界、碰撞合并优化

@export_group("可行走区域配置")
@export var walkable_layers: Array[TileMapLayer] = []
## 需要所有层都有瓦片才算安全（false=任一存在即安全，true=全部存在才安全）
@export var require_all_layers: bool = false

@export_group("边界检测模式")
@export var boundary_mode: BoundaryMode = BoundaryMode.BOTH
## 边界厚度（像素）
@export var boundary_thickness: float = 4.0
## 是否启用碰撞合并优化（大幅减少碰撞体数量）
@export var merge_segments: bool = true

@export_group("碰撞配置")
@export var collision_layer: int = 1
@export var collision_mask: int = 2

@export_group("瓦片配置")
@export var tile_size: Vector2i = Vector2i(16, 16)

@export_group("调试")
@export var debug_draw: bool = false
@export var debug_color: Color = Color(0.049, 0.611, 0.613, 0.5)
@export var debug_line_width: float = 2.0

enum BoundaryMode {
	OUTER_ONLY,  ## 只检测外边界（走出安全区）
	INNER_ONLY,  ## 只检测内边界（安全区内的危险区域）
	BOTH         ## 内外边界都检测
}

enum Direction {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

# 存储生成的碰撞体节点，用于清理
var _generated_bodies: Array[StaticBody2D] = []
# 存储边界线用于调试绘制
var _debug_lines: Array[Dictionary] = []

func _ready() -> void:
	if walkable_layers.is_empty():
		push_warning("BoundaryGenerator: walkable_layers 为空，请在编辑器中配置可行走层")
		return
	
	# 延迟一帧生成，确保 TileMapLayer 已完全加载
	call_deferred("_generate_boundary_collisions")

func _generate_boundary_collisions() -> void:
	# 清理旧碰撞体
	_clear_existing_collisions()
	
	# 获取所有安全区域的格子
	var safe_cells: Dictionary = _get_safe_cells()
	if safe_cells.is_empty():
		push_warning("BoundaryGenerator: 没有找到安全区域格子")
		return
	
	# 检测边界
	var edges: Array[Dictionary] = _detect_boundaries(safe_cells)
	if edges.is_empty():
		return
	
	# 合并相邻边界（优化）
	if merge_segments:
		edges = _merge_edges(edges)
	
	# 生成碰撞体
	_create_collision_shapes(edges)
	
	print("BoundaryGenerator: 生成了 %d 个碰撞边界段" % edges.size())

## 获取所有安全的格子（可在上面行走）
func _get_safe_cells() -> Dictionary:
	var safe_cells: Dictionary = {}
	
	for layer in walkable_layers:
		if layer == null:
			continue
		
		var cells: Array[Vector2i] = layer.get_used_cells()
		for cell in cells:
			if require_all_layers:
				# 需要所有层都有，先标记候选
				if not safe_cells.has(cell):
					safe_cells[cell] = 1
				else:
					safe_cells[cell] += 1
			else:
				# 任一存在即安全
				safe_cells[cell] = true
	
	# 如果 require_all_layers，过滤只保留出现在所有层的格子
	if require_all_layers:
		var filtered: Dictionary = {}
		var layer_count: int = walkable_layers.size()
		for cell in safe_cells:
			if safe_cells[cell] >= layer_count:
				filtered[cell] = true
		return filtered
	
	return safe_cells

## 检测边界
func _detect_boundaries(safe_cells: Dictionary) -> Array[Dictionary]:
	var edges: Array[Dictionary] = []
	_debug_lines.clear()
	
	for cell in safe_cells:
		var cell_pos: Vector2i = cell as Vector2i
		
		# 检查四个方向
		var neighbors: Dictionary = {
			Direction.TOP: cell_pos + Vector2i.UP,
			Direction.BOTTOM: cell_pos + Vector2i.DOWN,
			Direction.LEFT: cell_pos + Vector2i.LEFT,
			Direction.RIGHT: cell_pos + Vector2i.RIGHT
		}
		
		for dir in neighbors:
			var neighbor: Vector2i = neighbors[dir]
			var is_neighbor_safe: bool = safe_cells.has(neighbor)
			
			# 判断是否需要生成边界
			var should_add: bool = false
			
			match boundary_mode:
				BoundaryMode.OUTER_ONLY:
					# 外边界：安全区域的邻居不安全
					should_add = not is_neighbor_safe
				BoundaryMode.INNER_ONLY:
					# 内边界：只检测外部不安全区域（实际就是 OUTER_ONLY 的反向，但这里安全区域是内部）
					# 内边界是安全区域内部的空洞
					should_add = not is_neighbor_safe
				BoundaryMode.BOTH:
					should_add = not is_neighbor_safe
			
			if should_add:
				var edge: Dictionary = _create_edge_data(cell_pos, dir)
				edges.append(edge)
				
				if debug_draw:
					_debug_lines.append({
						"from": edge.start_pos,
						"to": edge.end_pos,
						"color": debug_color
					})
	
	return edges

## 创建边界数据
func _create_edge_data(cell: Vector2i, dir: Direction) -> Dictionary:
	var world_pos: Vector2 = _get_world_position(cell)
	var half_size: Vector2 = Vector2(tile_size) / 2.0
	
	var start_pos: Vector2
	var end_pos: Vector2
	
	match dir:
		Direction.TOP:
			start_pos = world_pos - half_size
			end_pos = world_pos + Vector2(half_size.x, -half_size.y)
		Direction.BOTTOM:
			start_pos = world_pos + Vector2(-half_size.x, half_size.y)
			end_pos = world_pos + half_size
		Direction.LEFT:
			start_pos = world_pos - half_size
			end_pos = world_pos + Vector2(-half_size.x, half_size.y)
		Direction.RIGHT:
			start_pos = world_pos + Vector2(half_size.x, -half_size.y)
			end_pos = world_pos + half_size
	
	return {
		"cell": cell,
		"direction": dir,
		"start_pos": start_pos,
		"end_pos": end_pos
	}

## 合并相邻的边界段（优化碰撞体数量）
func _merge_edges(edges: Array[Dictionary]) -> Array[Dictionary]:
	# 按方向分组
	var edges_by_dir_top: Array[Dictionary] = []
	var edges_by_dir_bottom: Array[Dictionary] = []
	var edges_by_dir_left: Array[Dictionary] = []
	var edges_by_dir_right: Array[Dictionary] = []
	
	for edge in edges:
		match edge.direction:
			Direction.TOP:
				edges_by_dir_top.append(edge)
			Direction.BOTTOM:
				edges_by_dir_bottom.append(edge)
			Direction.LEFT:
				edges_by_dir_left.append(edge)
			Direction.RIGHT:
				edges_by_dir_right.append(edge)
	
	var merged: Array[Dictionary] = []
	
	# 处理 TOP 和 BOTTOM 方向：按 Y 分组，X 排序后合并
	for dir_edges in [edges_by_dir_top, edges_by_dir_bottom]:
		if dir_edges.is_empty():
			continue
		
		# 按 Y 坐标分组
		var by_y: Dictionary = {}
		for edge in dir_edges:
			var y: int = (edge.cell as Vector2i).y
			if not by_y.has(y):
				by_y[y] = []
			by_y[y].append(edge)
		
		# 每组内按 X 排序并合并
		for y in by_y:
			var row_edges: Array = by_y[y]
			row_edges.sort_custom(func(a, b): return (a.cell as Vector2i).x < (b.cell as Vector2i).x)
			merged.append_array(_merge_continuous_edges(row_edges, true))
	
	# 处理 LEFT 和 RIGHT 方向：按 X 分组，Y 排序后合并
	for dir_edges in [edges_by_dir_left, edges_by_dir_right]:
		if dir_edges.is_empty():
			continue
		
		# 按 X 坐标分组
		var by_x: Dictionary = {}
		for edge in dir_edges:
			var x: int = (edge.cell as Vector2i).x
			if not by_x.has(x):
				by_x[x] = []
			by_x[x].append(edge)
		
		# 每组内按 Y 排序并合并
		for x in by_x:
			var col_edges: Array = by_x[x]
			col_edges.sort_custom(func(a, b): return (a.cell as Vector2i).y < (b.cell as Vector2i).y)
			merged.append_array(_merge_continuous_edges(col_edges, false))
	
	return merged

## 合并连续的边界段
func _merge_continuous_edges(edges, is_horizontal):
	if edges.size() <= 1:
		return edges.duplicate()
	
	var merged = []
	var current_start = edges[0].start_pos
	var current_end = edges[0].end_pos
	var last_cell = edges[0].cell
	
	for i in range(1, edges.size()):
		var edge = edges[i]
		var current_cell = edge.cell
		
		# 检查是否连续
		var is_continuous = false
		if is_horizontal:
			is_continuous = (current_cell.y == last_cell.y) and (current_cell.x == last_cell.x + 1)
		else:
			is_continuous = (current_cell.x == last_cell.x) and (current_cell.y == last_cell.y + 1)
		
		if is_continuous:
			# 合并，延伸终点
			current_end = edge.end_pos
			last_cell = current_cell
		else:
			# 不连续，保存当前段，开始新段
			merged.append({
				"cell": edges[i-1].cell,
				"direction": edges[i-1].direction,
				"start_pos": current_start,
				"end_pos": current_end
			})
			current_start = edge.start_pos
			current_end = edge.end_pos
			last_cell = current_cell
	
	# 添加最后一段
	merged.append({
		"cell": edges[-1].cell,
		"direction": edges[-1].direction,
		"start_pos": current_start,
		"end_pos": current_end
	})
	
	return merged

## 创建碰撞形状
func _create_collision_shapes(edges: Array[Dictionary]) -> void:
	var container: Node2D = Node2D.new()
	container.name = "BoundaryCollisions"
	add_child(container)
	
	for edge in edges:
		var body: StaticBody2D = StaticBody2D.new()
		body.collision_layer = collision_layer
		body.collision_mask = collision_mask
		body.name = "Boundary_%s_%s" % [edge.cell, _dir_to_string(edge.direction)]
		
		var shape: CollisionShape2D = CollisionShape2D.new()
		var segment: SegmentShape2D = SegmentShape2D.new()
		
		# 稍微加厚边界以提高碰撞稳定性
		var direction: Vector2 = (edge.end_pos - edge.start_pos).normalized()
		var normal: Vector2 = Vector2(-direction.y, direction.x)
		var offset: Vector2 = normal * (boundary_thickness / 2.0)
		
		segment.a = edge.start_pos
		segment.b = edge.end_pos
		
		shape.shape = segment
		shape.position = (edge.start_pos + edge.end_pos) / 2.0
		
		# 使用 RectangleShape2D 代替 SegmentShape2D 以获得更好的碰撞响应
		var rect_shape: RectangleShape2D = RectangleShape2D.new()
		var length: float = edge.start_pos.distance_to(edge.end_pos)
		rect_shape.size = Vector2(length, boundary_thickness)
		
		# 计算角度
		var angle: float = direction.angle()
		shape.rotation = angle
		shape.shape = rect_shape
		
		body.add_child(shape)
		container.add_child(body)
		_generated_bodies.append(body)

## 清理已生成的碰撞体
func _clear_existing_collisions() -> void:
	var container: Node = get_node_or_null("BoundaryCollisions")
	if container:
		container.queue_free()
	
	_generated_bodies.clear()

## 获取格子的世界坐标（考虑 TileMapLayer 的偏移）
func _get_world_position(cell: Vector2i) -> Vector2:
	# 使用第一个层的偏移作为基准
	if walkable_layers.is_empty() or walkable_layers[0] == null:
		return Vector2(cell.x * tile_size.x, cell.y * tile_size.y)
	
	var base_layer: TileMapLayer = walkable_layers[0]
	var local_pos: Vector2 = base_layer.map_to_local(cell)
	
	# 转换为世界坐标
	return base_layer.to_global(local_pos)

func _dir_to_string(dir: Direction) -> String:
	match dir:
		Direction.TOP: return "TOP"
		Direction.BOTTOM: return "BOTTOM"
		Direction.LEFT: return "LEFT"
		Direction.RIGHT: return "RIGHT"
	return "UNKNOWN"

## 调试绘制
func _draw() -> void:
	if not debug_draw or _debug_lines.is_empty():
		return
	
	for line in _debug_lines:
		draw_line(line.from, line.to, line.color, debug_line_width)

## 重新生成边界（可在运行时调用）
func regenerate() -> void:
	_generate_boundary_collisions()
	if debug_draw:
		queue_redraw()

## 清除所有边界碰撞
func clear_boundaries() -> void:
	_clear_existing_collisions()
	_debug_lines.clear()
	if debug_draw:
		queue_redraw()
