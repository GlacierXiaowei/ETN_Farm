extends Node
class_name NoPlacement

## 禁止放置区域状态（如房子内部、建筑物周围等）
## 当玩家进入 no_placement_zone 组的 InteractableComponent 区域时变为 true
var in_no_placement_zones : bool = false

## 全局组名，用于标识禁止放置/耕种的区域
const GROUP_NAME : String = "no_placement_zone"

func _ready() -> void:
	## 防御性编程：确保组名正确
	_connect_to_group()

## 连接全局组的信号
func _connect_to_group() -> void:
	## 延迟一帧执行，确保场景节点已完全加载
	await get_tree().process_frame
	
	## 获取所有在 no_placement_zone 组的节点
	var nodes = get_tree().get_nodes_in_group(GROUP_NAME)
	
	## 连接每个节点的信号
	for node in nodes:
		_connect_node_signals(node)

## 连接单个节点的信号
func _connect_node_signals(node : Node) -> void:
	## 如果节点本身就是 InteractableComponent，直接连接
	if node is InteractableCompenent:
		_connect_interactable_component(node)
		return
	
	## 否则查找子节点中的 InteractableComponent
	for child in node.get_children():
		if child is InteractableCompenent:
			_connect_interactable_component(child)

## 连接 InteractableComponent 的信号
func _connect_interactable_component(comp : InteractableCompenent) -> void:
	if comp.has_signal("interactable_activated"):
		if not comp.interactable_activated.is_connected(_on_interactable_activated):
			comp.interactable_activated.connect(_on_interactable_activated)
	
	if comp.has_signal("interactable_deactivated"):
		if not comp.interactable_deactivated.is_connected(_on_interactable_deactivated):
			comp.interactable_deactivated.connect(_on_interactable_deactivated)

## 当进入禁止区域时调用
func _on_interactable_activated(_body : Node2D = null) -> void:
	in_no_placement_zones = true

## 当离开禁止区域时调用
func _on_interactable_deactivated(_body : Node2D = null) -> void:
	in_no_placement_zones = false

## 获取当前是否在禁止区域
func is_in_no_placement_zone() -> bool:
	return in_no_placement_zones
