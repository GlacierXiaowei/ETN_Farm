extends Node
class_name SaveLevelDataComponent

var level_scene_name : String
var save_game_data_path: String = "user://game_data/"
var save_file_name: String = "save_%s_game_data.tres"
var game_data_resource: SaveGameDataResource

func _ready() -> void:
	add_to_group("save_level_data_manager")
	level_scene_name = get_parent().name


func save_node_data() -> void:
	var node = get_tree().get_nodes_in_group("save_data_component")
	
	print("[DEBUG] 找到的 SaveDataComponent 数量: ", node.size())
	for i in range(node.size()):
		var parent = node[i].get_parent()
		var parent_name = parent.name if parent != null else "no parent"
		print("[DEBUG] 组件 ", i, ": ", parent_name)
	
	game_data_resource = SaveGameDataResource.new()
	print("[DEBUG] game_data_resource 创建成功, save_data_node 大小: ", game_data_resource.save_data_node.size())
	
	if node != null:
		for _node:SaveDataComponent in node:
			var parent = _node.get_parent()
			var parent_name = parent.name if parent != null else "no parent"
			print("[DEBUG] 正在处理节点: ", parent_name)
			if _node is SaveDataComponent:
				print("[DEBUG] 节点是 SaveDataComponent，开始保存数据...")
				var save_data_resource: NodeDataResource = _node._save_data()
				if save_data_resource != null:
					print("[DEBUG] 获取到资源: ", save_data_resource)
					var save_final_resource = save_data_resource.duplicate()
					game_data_resource.save_data_node.append(save_final_resource)
					print("[DEBUG] 资源已添加到数组，当前数组大小: ", game_data_resource.save_data_node.size())
				else:
					print("[ERROR] _save_data() 返回了 null!")
			else:
				print("[DEBUG] 节点不是 SaveDataComponent，跳过")
	
	print("[DEBUG] 保存循环结束，最终数组大小: ", game_data_resource.save_data_node.size())


func save_game() -> void:
	if !DirAccess.dir_exists_absolute(save_game_data_path):
		DirAccess.make_dir_absolute(save_game_data_path)
		
	var level_save_file_name = save_file_name % level_scene_name
	
	save_node_data()
	
	var result : int = ResourceSaver.save(game_data_resource,save_game_data_path + level_save_file_name)
	print("Save result: ",result)


func load_game() ->void:
	var level_save_file_name: String = save_file_name % level_scene_name
	var save_game_path: String = save_game_data_path + level_save_file_name
	
	if ! FileAccess.file_exists(save_game_path):
		return
	
	game_data_resource = ResourceLoader.load(save_game_path)
	
	if game_data_resource == null :
		return
		
	var root_node: Window = get_tree().root
	
	for resource in game_data_resource.save_data_node:
		if resource is NodeDataResource:
			resource._load_data(root_node)
