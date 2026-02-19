extends Node
##已注册为单例 此为库存管理器
#注意 为了保证节点名称的一致性 我们采用 大写 或者主动使用大写转换保证一致性
var inventory: Dictionary = Dictionary()

signal inventory_change


func add_collectable(collectable_name: String,amount:int =1) -> void:
	##添加物品，可选数量
	var key = collectable_name.capitalize()
	inventory.get_or_add(key)
	
	if inventory[key] == null:
		inventory[key] = 1
	else:
		for i in amount:
			inventory[key] +=1
		

	inventory_change.emit()


func remove_collectable(collectable_name: String,amount:int =1) -> void:
	var key = collectable_name.capitalize()
	if inventory[key] == null:
		inventory[key] = 0
	else:
		if inventory[key] > 0 :
			for i in amount:
				inventory[key] -=1
		
	
	inventory_change.emit()



##投降了 这个函数好几个 要用到chest的我没办法了
#func feed_animal(inventory_item:String , scene:)-> void:
	
