extends Node


##save_game的调用也在player逻辑中

func save_game()-> void:
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_data_component")
	
	if save_level_data_component!= null:
		save_level_data_component.save_game()
		
func load_game() -> void:
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_data_component")
	
	if save_level_data_component != null:
		save_level_data_component.load_game()
