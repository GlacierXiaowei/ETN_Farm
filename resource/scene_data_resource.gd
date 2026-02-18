extends NodeDataResource
class_name SceneDataResource


@export var node_name: String
@export var scene_file_path: String

func _save_data(node: Node2D) -> void:
	super._save_data(node)
	
	node_name = node.name
	scene_file_path = node.scene_file_path

func _load_data(window: Window) -> void:
	# 先尝试查找已存在的节点（如玩家）
	var existing_node = window.get_node_or_null(node_path)
	
	if existing_node != null:
		# 节点已存在（如玩家），直接恢复位置
		existing_node.global_position = global_position
	else:
		# 节点不存在，需要实例化（如作物、掉落物品）
		var parent_node = window.get_node_or_null(parent_node_path)
		
		if parent_node != null and scene_file_path != "" and scene_file_path != null:
			var scene_file_resource = load(scene_file_path)
			if scene_file_resource != null:
				var scene_node = scene_file_resource.instantiate() as Node2D
				if scene_node != null:
					scene_node.global_position = global_position
					parent_node.add_child(scene_node)
	
		
