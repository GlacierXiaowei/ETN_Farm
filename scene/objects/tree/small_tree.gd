extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var hp_component: HpComponent = $HpComponent

@export var drop_radius: int = 8

var pre_log_scene = preload("res://scene/objects/tree/log.tscn")

func _ready() -> void:
	#稍微解释一下 这个hurt返回对应的hit_component的单次攻击伤害 在本脚本中 传入到on_hurt
	#这个信号被绑定之后 顺着本脚本的on_hurt 将单次的hit伤害传给 Hp_component 的
	#计算生命值的地方 综上所述 在这个小树实体
	#武器的伤害由武器对应的hit_component 的导出参数决定
	#被攻击试题的生命值 由该实体的HpComponent 的导出变量决定
	#信号传递 借鉴下列代码 下列代码 就是将武器的伤害量 传递到hpCompnent中 并每次扣除单次武器hp
	hurt_component.hurt.connect(on_hurt)
	hp_component.zero_hp.connect(on_zero_hp)
	
	hurt_component.tool = DataType.Tools.AxeWood
	
	hp_component.max_hp = 3 
	hp_component.current_hp = 3
	
func on_hurt (damage: int) -> void :
	hp_component.apply_damage(damage)
	
	material.set_shader_parameter("shake_intensity",1.0)
	await get_tree().create_timer(0.85).timeout
	material.set_shader_parameter("shake_intensity",0.0)
	
func on_zero_hp() -> void :
	##该函数用于 等待当前tree空闲之后 在空闲帧延迟调用
	##尤其用于 改变关键属性 比如添加子节点 改变/删除父节点等等 
	##当树结构变化（添加删除节点） 或者物理帧/物理回调
	##以及 信号回调的时候（比如现在这个 回调函数）
	##一般情况下 其实没得问题 
	##还有就是 在_ready() 不能删除节点
	##在 exit_tree中 不能够添加节点 这两种情况容易触发场景树锁
	##这个时候将会触发 场景树锁 拒绝更改树的结构 
	##所以需要使用 call_deferred 来在空闲的时候进行
	##queue_free() 也是call_deferred的一种 
	##先执行 call_deferred的执行队列 （注意 .free() 是立刻删除 谨慎使用）
	##但是 多个call_deffered的执行顺序 这个我查了一下gpt 也没弄明白 有点复杂
	##总之呢 我们按照一般的逻辑去处理 一般就是我们的调用顺序
	call_deferred("add_log_scene")
	print("受击对象现在生命值为0")
	queue_free()

func add_log_scene() ->void:
	var log_scene = pre_log_scene.instantiate() as Node2D
	var base_position = self.global_position #+ Vector2(0, 8)
	var random_offset = get_random_offset_in_circle(drop_radius)
	log_scene.global_position = base_position + random_offset
	get_tree().root.add_child(log_scene)

func get_random_offset_in_circle(radius: int) -> Vector2:
	var angle = randf() * TAU
	var distance_from_center = sqrt(randf()) * radius
	var x = distance_from_center * cos(angle)
	var y = distance_from_center * sin(angle)
	return Vector2(x, y)
