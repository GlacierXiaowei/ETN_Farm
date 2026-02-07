extends Node2D
class_name HpComponent

#一个是 该物体的总血量 一个是目前的血量 并赋予默认值
@export var max_hp = 1
@export var current_hp = 1

signal zero_hp

func apply_damage(damage : int) -> void:
	#clamp(value,min,max) 返回value 并使value的值 不大于最大，不小于最小
	current_hp = clampi(current_hp - damage, 0 , max_hp)
	
	if current_hp == 0:
		zero_hp.emit()
