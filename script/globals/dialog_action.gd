extends Node
## 对话动作处理器
## 暴露给 Dialogue Manager 的回调接口
## 用法：do DialogAction.give_item("Corn", 3)


## 给予玩家物品 注意 我们调用函数和调用函数其实差不多 我就直接调用函数了
## @param item_name: 物品名称（如 "Corn", "Tomato"）
## @param amount: 数量，默认1个
func give_item(item_name: String, amount: int = 1) -> void:
	#print("[DialogAction] Giving ", amount, "x ", item_name)
	for i in range(amount):
		InventoryManager.add_collectable(item_name)

signal on_feed_animal
func feed_animal( ) ->void:
	on_feed_animal.emit()
