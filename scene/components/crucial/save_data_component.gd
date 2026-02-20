extends Node
#class_name SaveDataComponent

##注意 父节点将会被强制转换为Node2d
@onready var parent_node: Node2D = self.get_parent() as Node2D

@export var save_data_resource: Resource

func _ready() -> void:
	add_to_group("save_data_component")


func _save_data() -> Resource:
	if parent_node == null:
		push_error("SaveDataComponent: parent_node is null")
		return null
	if save_data_resource == null:
		push_error("SaveDataComponent: save_data_resource is null for node: " + parent_node.name)
		return null
	
	# 检查资源类型是否正确
	if save_data_resource is SaveGameDataResource:
		push_error("SaveDataComponent: 错误！save_data_resource 不能是 SaveGameDataResource！请使用 SceneDataResource 或 TileMapLayerDataResource。节点：" + parent_node.name)
		return null
	
	# 检查是否有 _save_data 方法
	if not save_data_resource.has_method("_save_data"):
		push_error("SaveDataComponent: save_data_resource 没有 _save_data 方法！资源类型：" + str(save_data_resource.get_class()) + "，节点：" + parent_node.name)
		return null
	
	save_data_resource._save_data(parent_node)
	
	return save_data_resource
