extends Node

var game_menu_preload = preload("res://scene/game_main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		show_game_menu()


func start_game()-> void:
	SaveGameManager.allow_save_game = true
	SceneManager.load_main_scene_container()
	SceneManager.load_level("level1")
	SaveGameManager.load_game()



func exit_game()-> void:
	get_tree().quit()


func show_game_menu()-> void:
	var game_menu_instance = game_menu_preload.instantiate()
	get_tree().root.add_child(game_menu_instance)
	
