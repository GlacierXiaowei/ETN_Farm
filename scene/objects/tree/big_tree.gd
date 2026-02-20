##复用自 小树场景 所有注释已移除 如有需要 请前往相关的场景
extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var hp_component: HpComponent = $HpComponent

@export var drop_radius: int = 8

var pre_log_scene = preload("res://scene/objects/tree/log.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	hp_component.zero_hp.connect(on_zero_hp)
	
	#
	hurt_component.tool = DataType.Tools.AxeWood
	
	hp_component.max_hp = 8 
	hp_component.current_hp = 8
	
func on_hurt (damage: int) -> void :
	hp_component.apply_damage(damage)
	
	material.set_shader_parameter("shake_intensity",0.8)
	await get_tree().create_timer(0.55).timeout
	material.set_shader_parameter("shake_intensity",0.0)

func on_zero_hp() -> void :
	call_deferred("add_log_scene")
	print("受击对象现在生命值为0") 
	queue_free()

func add_log_scene() -> void:
	var log_scene = pre_log_scene.instantiate() as Node2D
	var base_position = self.global_position #+ Vector2(0, 12)
	var random_offset = get_random_offset_in_circle(drop_radius)
	log_scene.global_position = base_position + random_offset
	get_tree().root.add_child(log_scene)

func get_random_offset_in_circle(radius: int) -> Vector2:
	var angle = randf() * TAU
	var distance_from_center = sqrt(randf()) * radius
	var x = distance_from_center * cos(angle)
	var y = distance_from_center * sin(angle)
	return Vector2(x, y)
