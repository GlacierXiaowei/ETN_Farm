extends Node
class_name SaveDataComponent

##注意 父节点将会被强制转换为Node2d
@onready var parent_node: Node2D = self.get_parent() as Node2D

@export var save_data_resource: Resource

func _ready() -> void:
	add_to_group("save_data_component")


func _save_data() -> Resource:
	if parent_node ==null:
		return null
	if save_data_resource == null:
		push_error("save_data_resource:",save_data_resource,parent_node.name)
	
	save_data_resource._save_data(parent_node)
	
	return save_data_resource
