extends Node
class_name DirtCursorComponent

@export var grass_tilemap_layer: TileMapLayer
@export var dirt_tilemap_layer: TileMapLayer
@export var terrain_set: int = 0
##这个指的是 地形的id(=4) 不是sorce id(=9) 填写正确
@export var terrain: int = 4

##耕地预览格
@export var enable_preview: bool = true
@onready var preview_sprite: Sprite2D 


##是否使用 鼠标点击位置优先
@export var use_mouse_mode: bool = false

##onready是指刚好在该节点的ready之前调用
##该函数获取子节点或者同级的player
var player: Player 


var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	update_preview()



##使用工具锄头的方法 统一整合至player的unhandled统一管理 根据是否有节点接入 来决定


func update_target_cell() -> bool:
	if use_mouse_mode:
		get_cell_under_mouse()
		
		# 鼠标模式才检测距离
		if distance > 25.0:
			return false
	else:
		get_cell_in_front_of_player()
	
	# 无瓦片直接失败
	if cell_source_id == -1:
		return false
	
	return true


##用于获取 鼠标下方对应的（草地）瓦片地图的位置 （这里会使用到咱们的本地地图）
func get_cell_under_mouse() ->void:
	mouse_position = grass_tilemap_layer.get_local_mouse_position()
	cell_position = grass_tilemap_layer.local_to_map(mouse_position)
	cell_source_id = grass_tilemap_layer.get_cell_source_id(cell_position)
	##注意 如果统一全局使用全局位置 需要让这些个图块transform的偏移相同 否则会有显示偏差
	##（相当于 实际上位置一样 但是由于由transform的位移 所以建议统一为（0，0））
	local_cell_position = grass_tilemap_layer.map_to_local(cell_position)
	var cell_global_position = grass_tilemap_layer.to_global(local_cell_position)
	distance = player.global_position.distance_to(cell_global_position)
	#print("mouse_position: ",mouse_position," cell_position: ",cell_position," cell_source_id",cell_source_id)
	#print("distance: ",distance)


func get_cell_in_front_of_player() -> void:
	# 1️⃣ 如果没有方向，直接退出
	if player.player_direction == Vector2.ZERO:
		return
	
	# 2️⃣ 计算前方一个格子的全局坐标
	var offset: Vector2 = player.player_direction * 16
	var target_global_position: Vector2 = player.global_position + offset
	
	# 3️⃣ 转换成 tilemap 的本地坐标
	var target_local_position: Vector2 = grass_tilemap_layer.to_local(target_global_position)
	
	# 4️⃣ 转成格子坐标
	cell_position = grass_tilemap_layer.local_to_map(target_local_position)
	
	# 5️⃣ 读取这个格子的 source id
	cell_source_id = grass_tilemap_layer.get_cell_source_id(cell_position)
	
	# 6️⃣ 计算距离（给你的统一逻辑用）
	var cell_local_position = grass_tilemap_layer.map_to_local(cell_position)
	var cell_global_position = grass_tilemap_layer.to_global(cell_local_position)
	distance = player.global_position.distance_to(cell_global_position)


func add_till_soil_cell() -> void:
	##20.0 是指的像素
	##这个函数单纯变成添加耕地 判断不再由他负责
	if distance< 25.0 && cell_source_id == 1:
		dirt_tilemap_layer.set_cells_terrain_connect([cell_position],terrain_set,terrain, true)

func remove_till_soil_cell()->void:
	if distance< 25.0 && cell_source_id == 1 :
		dirt_tilemap_layer.set_cells_terrain_connect([cell_position],0,-1, true)


func on_till_tool_used() -> void:
	if !update_target_cell():
		return
	add_till_soil_cell()

func on_undo_till_tool_used() -> void:
	#if ToolManager.current_tool != DataType.Tools.TillGround:
		#return
	if !update_target_cell():
		return
	remove_till_soil_cell()


func update_preview() -> void:
	if ToolManager.current_tool!= DataType.Tools.TillGround:
		return
	
	if !enable_preview:
		preview_sprite.visible = false
		return
	
	if player.current_tool != DataType.Tools.TillGround:
		preview_sprite.visible = false
		return
	
	if !update_target_cell():
		preview_sprite.visible = false
		return
	
	preview_sprite.visible = true
	
	var cell_local_position = grass_tilemap_layer.map_to_local(cell_position)
	var cell_global_position = grass_tilemap_layer.to_global(cell_local_position)
	
	preview_sprite.global_position = cell_global_position
