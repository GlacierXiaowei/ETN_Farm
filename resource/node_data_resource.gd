class_name NodeDataResource
extends Resource

@export var global_position: Vector2
@export var node_path: NodePath
@export var parent_node_path : NodePath


func _save_data(node: Node2D) ->void:
	global_position = node.global_position
	##提示 这个会返回相对于场景书的绝对位置 换言之 即使在不同的场景中也总是正确的
	node_path = node.get_path()
	
	var parent_node = node.get_parent()
	
	if node.get_parent() :
		parent_node_path = parent_node.get_path()


@warning_ignore("unused_parameter")
func _load_data(window: Window) -> void:
	pass
