extends Area2D
class_name CollectableComponent

@export var collectable_name: String

func _ready() -> void:
	print("可收集对象生成: ",collectable_name)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("可收集对象被收集: ",collectable_name)
		InventoryManager.add_collectable(collectable_name)
		##这里的父节点 刚好是Log根节点
		get_parent().queue_free()
