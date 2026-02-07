extends Area2D
class_name HurtComponent

@export var tool : DataType.Tools = DataType.Tools.None

#如果使用 on_hurt会产生歧义
signal hurt


func _on_area_entered(area: Area2D) -> void:
	#把 area 变量尝试转换为HitComponent类型并返回（如果转换失败 返回null 不会报错）
	var hit_component = area as HitComponent
	
	#该判断是指 只有斧头可以砍树 两者必须匹配才行
	if tool == hit_component.current_tool:
		hurt.emit(hit_component.hit_damage)
