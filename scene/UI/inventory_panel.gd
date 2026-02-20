extends PanelContainer


@onready var inventory_label : Dictionary = Dictionary()

func _ready() -> void:
	InventoryManager.inventory_change.connect(on_inventory_change)
	

	for child in self.get_child(0).get_child(0).get_children():
		inventory_label[child.name.capitalize()] = child.get_node("Label") as Label
	
	##初始化？ 哈哈哈
	on_inventory_change()
	
func on_inventory_change() -> void:
	##inventory_num不用onready是因为 即使这个节点onready 
	##也不能说明InventoryManager初始化完毕 这个是更保险的写法
	var inventory_num : Dictionary = InventoryManager.inventory
	if inventory_num.is_empty() :
		return
	
	for key in inventory_num :
		var capitalized_key = key.capitalize()
		if not inventory_label.has(capitalized_key):
			continue
		##注意 Godot 不会将int 自动转换为str 这样手动操作一下会更加安全
		inventory_label[capitalized_key].text = str(inventory_num[key])
