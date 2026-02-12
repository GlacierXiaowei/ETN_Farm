extends Node

#注意 为了保证节点名称的一致性 我们采用 大写 或者主动使用大写转换保证一致性
var inventory: Dictionary = Dictionary()

signal inventory_change

func add_collectable(collectable_name: String) -> void:
	inventory.get_or_add(collectable_name.capitalize())
	
	if inventory[collectable_name] == null:
		inventory[collectable_name] = 1
	else:
		inventory[collectable_name] +=1
		
	inventory_change.emit()
