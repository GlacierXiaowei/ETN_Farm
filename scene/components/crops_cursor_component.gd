extends Node
class_name CropsCursorComponent

# --- 1. 核心引用 ---
@export_group("Nodes")
# 我们需要检测的是“耕地层”，因为种子只能种在耕地上
@export var dirt_tilemap_layer: TileMapLayer 
# 玩家引用 (会被 Player 自动赋值)
@export var player: Player 
@export var preview_sprite : Sprite2D
# 作物容器节点 (如果不指定，尝试自动查找名为 CropField 的节点)
@export var crop_parent: Node2D 

@export_group("Settings")
@export var enable_preview: bool = true
# 预览图 (请确保场景里这个节点下有个 Sprite2D)


@export var use_mouse_mode: bool = false
@export var max_interaction_distance: float = 25.0 

# --- 2. 预加载资源 ---
# 请确保这两个路径是正确的，如果不正确请修改
var corn_plant_pre = load("res://scene/objects/plant/corn.tscn")
var tomato_plant_pre = load("res://scene/objects/plant/tomato.tscn")

# 内部变量
var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var target_global_position: Vector2 # 目标格子的世界坐标
var distance: float

func _ready() -> void:
	# 自动查找 CropField 如果没赋值的话
	if not crop_parent and get_parent():
		crop_parent = get_parent().find_child("CropField")
		if not crop_parent:
			print("警告: CropsCursorComponent 未找到 CropField 节点，作物无法生成！")
	
	if preview_sprite:
		preview_sprite.visible = false

func _process(_delta: float) -> void:
	update_preview()

# --- 3. 核心计算逻辑 (参考 DirtCursorComponent) ---

func update_target_cell() -> bool:
	if !dirt_tilemap_layer or !player:
		return false

	if use_mouse_mode:
		get_cell_under_mouse()
	else:
		get_cell_in_front_of_player()
	
	# 1. 距离检测
	if distance > max_interaction_distance:
		return false
		
	# 2. 有效性检测：必须有耕地 (source_id != -1) 才能种
	# 假设 dirt_tilemap_layer 只有耕地块，如果有别的装饰块，可能需要判断 source_id
	if cell_source_id == -1:
		return false
	
	return true

func get_cell_under_mouse() -> void:
	mouse_position = dirt_tilemap_layer.get_local_mouse_position()
	cell_position = dirt_tilemap_layer.local_to_map(mouse_position)
	calculate_target_info()

func get_cell_in_front_of_player() -> void:
	if player.player_direction == Vector2.ZERO:
		return
	
	var offset: Vector2 = player.player_direction * 16
	var check_pos_global: Vector2 = player.global_position + offset
	var check_pos_local: Vector2 = dirt_tilemap_layer.to_local(check_pos_global)
	
	cell_position = dirt_tilemap_layer.local_to_map(check_pos_local)
	calculate_target_info()

func calculate_target_info() -> void:
	# 获取图块ID
	cell_source_id = dirt_tilemap_layer.get_cell_source_id(cell_position)
	
	# 计算中心点全局坐标
	var cell_local_pos = dirt_tilemap_layer.map_to_local(cell_position)
	target_global_position = dirt_tilemap_layer.to_global(cell_local_pos)
	
	# 计算距离
	distance = player.global_position.distance_to(target_global_position)

# --- 4. 动作入口 (由 Player 调用) ---

func on_plant_crop_used() -> void:
	if update_target_cell():
		add_crop()

func on_undo_plant_crop_used() -> void:
	if update_target_cell():
		remove_crop()

# --- 5. 种植与移除 ---

func add_crop() -> void:
	# 防止在同一个位置重复种植
	if is_crop_at_position(target_global_position):
		print("此处已有作物，无法种植")
		return

	var plant_scene: PackedScene = null
	
	if ToolManager.selected_tool == DataType.Tools.PlantCorn:
		plant_scene = corn_plant_pre
	elif ToolManager.selected_tool == DataType.Tools.PlantTomato:
		plant_scene = tomato_plant_pre
	
	if plant_scene and crop_parent:
		var plant_instance = plant_scene.instantiate() as Node2D
		plant_instance.global_position = target_global_position
		crop_parent.add_child(plant_instance)
		print("种植成功: ", plant_instance.name)

func remove_crop() -> void:
	if !crop_parent: return
	
	for node in crop_parent.get_children():
		if node is Node2D:
			# 使用距离判断而不是 ==，因为浮点数可能有微小误差
			if node.global_position.distance_to(target_global_position) < 1.0:
				node.queue_free()
				print("移除作物")
				break 

func is_crop_at_position(pos: Vector2) -> bool:
	if !crop_parent: return false
	for node in crop_parent.get_children():
		if node is Node2D and node.global_position.distance_to(pos) < 1.0:
			return true
	return false

# --- 6. 预览更新 ---

func update_preview() -> void:
	if !preview_sprite: return
	
	var tool = ToolManager.selected_tool
	# 只有当手里拿的是作物种子时才显示
	var is_seed_tool = (tool == DataType.Tools.PlantCorn or tool == DataType.Tools.PlantTomato)
	
	if !enable_preview or !is_seed_tool:
		preview_sprite.visible = false
		return
	
	if update_target_cell():
		preview_sprite.visible = true
		preview_sprite.global_position = target_global_position
		
		# 可选：根据种子类型改变预览颜色
		if tool == DataType.Tools.PlantCorn:
			preview_sprite.modulate = Color(1, 1, 0, 0.6) # 黄色
		else:
			preview_sprite.modulate = Color(1, 0, 0, 0.6) # 红色
	else:
		preview_sprite.visible = false
