extends Node
#SaveGameManager (全局管理器)
	#↓ 查找 "save_level_data_manager" 组
#SaveLevelDataComponent (场景存档管理员，每个场景1个)
	#↓ 查找 "save_data_component" 组  
#收集所有 SaveDataComponent (需要保存的节点，多个)
	#↓
#保存到文件

##save_game的调用也在player逻辑中

func save_game()-> void:
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_manager")
	
	if save_level_data_component!= null:
		save_level_data_component.save_game()
		
func load_game() -> void:
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_manager")
	
	if save_level_data_component != null:
		save_level_data_component.load_game()
