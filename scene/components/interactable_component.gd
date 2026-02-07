##这里就是检测 body进入了这个区域 可以同这个区域里面的交互 至于怎么交互 这就不是这个组件应该处理的问题了
##这个组件单纯用来检测区域的
##注意 不要在这个组件内部添加碰撞体积 
##不然每一次实例化 碰撞体积都一样 就不对 
##应该针对每个场景 自己在实例化的前提下再增加碰撞体积 这样每个场景的都不一样
class_name InteractableCompenent
extends Area2D

signal interactable_activated
signal interactable_deactivated


func _on_body_entered(_body: Node2D) -> void:
	interactable_activated.emit()


func _on_body_exited(_body: Node2D) -> void:
	interactable_deactivated.emit()
