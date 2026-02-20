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
	game_data_resource = SaveGameDataResource.new()
	
	if node != null:
		for _node:SaveDataComponent in node:
			if _node is SaveDataComponent:
				var save_data_resource: NodeDataResource = _node._save_data()
				if save_data_resource != null:
					var save_final_resource = save_data_resource.duplicate()
					game_data_resource.save_data_node.append(save_final_resource)


func save_game() -> void:
	if !DirAccess.dir_exists_absolute(save_game_data_path):
		DirAccess.make_dir_absolute(save_game_data_path)
		
	var level_save_file_name : String= save_file_name % level_scene_name
	
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
