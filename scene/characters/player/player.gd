class_name Player
extends CharacterBody2D

@export var current_tool:DataType.Tools = DataType.Tools.None

@onready var hit_componentt: HitComponent = $HitComponentt


##这个是 朝向 不是速度
#对于朝向和速度的修改已经迁移到 Walking状态中了
var player_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	
	##这个用于 单人模式下 给player.set_process_unhandled_input 绑定player
	GameInputEvent.player = self
	
	##注意 这里并没有采取初始化
	GameInputEvent.set_mode(GameInputEvent.current_mode)
	
func on_tool_selected(tool: DataType.Tools) ->void:
	current_tool=tool
	hit_componentt.current_tool=tool
	##这里的tool 是一个枚举类型 下列方式的调用会返回一个整数值 为其索引
	##从0开始 0指向None
	print("Tool: ",tool)


##该函数连通于 GameInputEvent 
##下列是控制 是否开启输入 也就是在开启UI的时候 可以关掉输入 
##player.set_process_unhandled_input(false)
##

func _unhandled_input(event: InputEvent) -> void:
	##该函数是收集未被ui组件使用的 InputEvent
	if event.is_action_pressed("hit"):
		GameInputEvent.request_use_tool()
	#GameInputEvent.current_mode == GameInputEvent.Mode.GAMEPLAY:
	
	for i in range(1, 10):
		if event.is_action_pressed("num_%d" % i):
			GameInputEvent.request_tool_select(i)
