##复用自 小树场景 所有注释已移除 如有需要 请前往相关的场景
extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var hp_component: HpComponent = $HpComponent

var pre_stone_scene = preload("res://scene/objects/rock/stone.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	hp_component.zero_hp.connect(on_zero_hp)
	
	#因为 没有稿子 这岩石只能使用斧头 之后我们再想办法吧
	hurt_component.tool = DataType.Tools.AxeWood
	
	hp_component.max_hp = 12 
	hp_component.current_hp = 12
	
func on_hurt (damage: int) -> void :
	hp_component.apply_damage(damage)
	
	material.set_shader_parameter("shake_intensity",0.3)
	await get_tree().create_timer(0.3).timeout
	material.set_shader_parameter("shake_intensity",0.0)

func on_zero_hp() -> void :
	call_deferred("add_stone_scene")
	print("受击对象现在生命值为0") 
	queue_free()

func add_stone_scene() ->void:
	var stone_scene = pre_stone_scene.instantiate() as Node2D
	stone_scene.global_position = self.global_position + Vector2(0,3)
	get_parent().add_child(stone_scene)
