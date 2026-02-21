extends Node2D


func _init() -> void:
	load_pck("user://patch/Patch_001.pck")


func load_all_pcks() -> bool:
	return false
	
func load_pck(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("PCK file not found: " + path)
		return false
	
	var loaded = ProjectSettings.load_resource_pack(path, true)
	if not loaded:
		push_error("Failed to load PCK: " + path)
	return loaded


func is_pck_official(path: String) -> bool:
	return true

func is_hash_corect(path: String) -> bool:
	return true
	
