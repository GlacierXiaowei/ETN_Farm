extends Node2D


func _init() -> void:
	load_all_pcks()


func load_all_pcks() -> bool:
	var patch_dir = "user://patch/"
	
	if not DirAccess.dir_exists_absolute(patch_dir):
		push_warning("Patch directory does not exist: " + patch_dir)
		return false
	
	var dir = DirAccess.open(patch_dir)
	if not dir:
		push_error("Failed to open patch directory: " + patch_dir)
		return false
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var pck_files: Array[String] = []
	
	while file_name != "":
		if file_name.begins_with("Patch") and file_name.ends_with(".pck"):
			pck_files.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	pck_files.sort_custom(func(a, b): return _extract_patch_number(a) < _extract_patch_number(b))
	
	var loaded_count = 0
	var failed_count = 0
	
	for file in pck_files:
		var full_path = patch_dir + file
		if load_pck(full_path):
			loaded_count += 1
		else:
			failed_count += 1
	
	print("PCK Loading: %d loaded, %d failed" % [loaded_count, failed_count])
	return loaded_count > 0 and failed_count == 0


func _extract_patch_number(file_name: String) -> int:
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(file_name)
	if result:
		return result.get_string().to_int()
	return 0
	
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
	
