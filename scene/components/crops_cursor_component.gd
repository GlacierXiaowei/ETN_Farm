extends Node
class_name CropsCursorComponent

# --- 1. 核心引用 ---
@export_group("Nodes")
@export var dirt_tilemap_layer: TileMapLayer 
@export var player: Player 
@export var preview_sprite : Sprite2D
@export var crop_parent: Node2D 

@export_group("Settings")
@export var enable_preview: bool = true
@export var use_mouse_mode: bool = false
@export var max_interaction_distance: float = 25.0 

# 内部变量 (保持和 Dirt 一致)
var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var target_global_position: Vector2
var distance: float

func _ready() -> void:
	if not crop_parent and get_parent():
		crop_parent = get_parent().find_child("CropField")
	
	await player.ready
	if preview_sprite:
		preview_sprite.visible = false

func _process(_delta: float) -> void:
	update_preview()

# --- 2. 核心计算逻辑 (完全照搬 DirtCursorComponent) ---

func update_target_cell() -> bool:
	if !dirt_tilemap_layer or !player:
		return false

	if use_mouse_mode:
		get_cell_under_mouse()
		# 鼠标模式照搬 Dirt：这里才检查距离
		if distance > max_interaction_distance:
			return false
	else:
		get_cell_in_front_of_player()
		# 键盘模式照搬 Dirt：这里【不】检查距离！
		# 这样能保证即使距离计算有微小偏差，也能先选中目标
	
	# 有效性检测 (种子特有：必须是耕地才能种/铲)
	if cell_source_id == -1:
		return false
	
	return true

func get_cell_under_mouse() -> void:
	mouse_position = dirt_tilemap_layer.get_local_mouse_position()
	cell_position = dirt_tilemap_layer.local_to_map(mouse_position)
	
	# 统一计算距离逻辑
	calculate_distance_and_pos()

func get_cell_in_front_of_player() -> void:
	# 1. 照搬 Dirt：没有方向直接退出
	if player.player_direction == Vector2.ZERO:
		return
	
	# 2. 照搬 Dirt：计算前方一格 (16像素)
	var offset: Vector2 = player.player_direction * 16
	var check_pos_global: Vector2 = player.global_position + offset
	
	# 3. 照搬 Dirt：转为格子坐标
	# 注意：Dirt 用的是 grass_tilemap，这里我们必须用 dirt_tilemap
	var check_pos_local: Vector2 = dirt_tilemap_layer.to_local(check_pos_global)
	cell_position = dirt_tilemap_layer.local_to_map(check_pos_local)
	
	# 4. 统一计算距离逻辑
	calculate_distance_and_pos()

# 辅助函数：统一 Dirt 的最后几步距离计算
func calculate_distance_and_pos() -> void:
	cell_source_id = dirt_tilemap_layer.get_cell_source_id(cell_position)
	
	var cell_local_pos = dirt_tilemap_layer.map_to_local(cell_position)
	target_global_position = dirt_tilemap_layer.to_global(cell_local_pos)
	
	distance = player.global_position.distance_to(target_global_position)

# --- 3. 动作入口 ---

func on_plant_crop_used() -> void:
	if !update_target_cell():
		return
	add_crop()

func on_undo_plant_crop_used() -> void:
	if !update_target_cell():
		return
	remove_crop()

# --- 4. 种植与移除 (照搬 Dirt 的检查逻辑) ---

func add_crop() -> void:
	# 照搬 Dirt：动作执行时才检查距离
	if distance > max_interaction_distance:
		return

	if is_crop_at_position(target_global_position):
		return

	var plant_scene: PackedScene = null
	if ToolManager.selected_tool == DataType.Tools.PlantCorn:
		plant_scene = load("res://scene/objects/plant/corn.tscn")
	elif ToolManager.selected_tool == DataType.Tools.PlantTomato:
		plant_scene = load("res://scene/objects/plant/tomato.tscn")
	
	if plant_scene and crop_parent:
		var plant_instance = plant_scene.instantiate() as Node2D
		plant_instance.global_position = target_global_position
		crop_parent.add_child(plant_instance)

func remove_crop() -> void:
	# 照搬 Dirt：动作执行时才检查距离
	# 这样 Undo 时，只要选中了格子（哪怕在脚下），距离检查通过就能铲
	if distance > max_interaction_distance:
		return

	if !crop_parent: return
	
	for node in crop_parent.get_children():
		if node is Node2D:
			# 这里保留 < 1.0 的判断，这是为了确认“那个格子上有没有作物”
			if node.global_position.distance_to(target_global_position) < 1.0:
				node.queue_free()
				break 

func is_crop_at_position(pos: Vector2) -> bool:
	if !crop_parent: return false
	for node in crop_parent.get_children():
		if node is Node2D and node.global_position.distance_to(pos) < 1.0:
			return true
	return false

# --- 5. 预览更新 (照搬 Dirt 的逻辑结构) ---
func update_preview() -> void:
	if !preview_sprite: return
	
	var tool = ToolManager.selected_tool
	var is_seed_tool = (tool == DataType.Tools.PlantCorn or tool == DataType.Tools.PlantTomato)
	
	if !enable_preview or !is_seed_tool:
		preview_sprite.visible = false
		return
	
	# 照搬 Dirt：就算距离远，只要 update_target_cell 返回 true (有耕地)，就显示预览
	# Dirt 是这么做的，这样你会看到远处的红框，但按键没反应（被 distance 拦截）
	if update_target_cell():
		preview_sprite.visible = true
		preview_sprite.global_position = target_global_position
	else:
		preview_sprite.visible = false
