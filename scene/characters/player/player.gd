class_name Player
extends CharacterBody2D

@export var current_tool:DataType.Tools = DataType.Tools.None
@export var dirt_cursor_component: DirtCursorComponent 
#@export var crops_cursor_component: CropsCursorComponent

@onready var hit_componentt: HitComponent = $HitComponentt
@onready var tilling: NodeState = $StateMachine/Tilling
#@onready var plant_corn: NodeState = $StateMachine/PlantCorn
#@onready var plant_tomato: NodeState = $StateMachine/PlantTomato



##这个是 朝向 不是速度
#对于朝向和速度的修改已经迁移到 Walking状态中了
var player_direction: Vector2 = Vector2.ZERO

##till返回的信号 仍然是 use_tool 使用改变量区分即可
var is_undo_use_tool_mode: bool = false

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	
	##这个用于 单人模式下 给player.set_process_unhandled_input 绑定player
	GameInputEvent.player = self
	
	##注意 这里并没有采取初始化
	GameInputEvent.set_mode(GameInputEvent.current_mode)
	
	##自动查找并链接DirtCursorComponent以及corncursor的
	for child in self.get_children():
		if child is DirtCursorComponent:
			dirt_cursor_component = child
			break
	if get_parent() :
		dirt_cursor_component = get_parent().get_node_or_null("DirtCursorComponent") as DirtCursorComponent
	if dirt_cursor_component:
		dirt_cursor_component.player = self
		dirt_cursor_component.preview_sprite=self.get_node("DirtPreview")
	
	#for child in self.get_children():
		#if child is CropsCursorComponent:
			#crops_cursor_component = child
			#break
	#if get_parent() :
		#crops_cursor_component = get_parent().get_node_or_null("CropsCursorComponent") as CropsCursorComponent
		#crops_cursor_component.player = self
		#crops_cursor_component.preview_sprite=self.get_node("DirtPreview")
	
	tilling.till_tool_used.connect(on_till_tool_used)
	#plant_corn.corn_planted_used.connect(on_plant_crop_used)
	#plant_tomato.tomato_planted_used.connect(on_plant_crop_used)
	
func on_tool_selected(tool: DataType.Tools) ->void:
	current_tool=tool
	hit_componentt.current_tool=tool
	##这里的tool 是一个枚举类型 下列方式的调用会返回一个整数值 为其索引
	##从0开始 0指向None
	print("Tool: ",tool)


##该函数连通于 GameInputEvent 
##下列是控制 是否开启输入 也就是在开启UI的时候 可以关掉输入 
##player.set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	for i in range(1, 10):
		if event.is_action_pressed("num_%d" % i):
			GameInputEvent.request_tool_select(i)
	
	##该函数是收集未被ui组件使用的 InputEvent
	##这里不让该系统发送信号 不实际处理逻辑 而是让tilling 节点管理哦
	if event.is_action_pressed("hit"):
		GameInputEvent.request_use_tool()
		#is_undo_use_tool_mode = false
		
	
	if event.is_action_pressed("undo_hit"):
		GameInputEvent.request_undo_use_tool()
		#is_undo_use_tool_mode = true
		
	
	#GameInputEvent.current_mode == GameInputEvent.Mode.GAMEPLAY:


func on_till_tool_used():
	##由于 咱们会公用 快捷键左键 为了安全起见 可以先检查 undo 再用elif/else 检查另一个 
	if dirt_cursor_component:
		if is_undo_use_tool_mode:
			#if crops_cursor_component:
				#crops_cursor_component.on_undo_plant_crop_used()
			#else:
				#print("错误: 清除耕地应该先清除上面的作物 但是无法连接CropCursorComponent节点。")
			dirt_cursor_component.on_undo_till_tool_used()
		else:
			dirt_cursor_component.on_till_tool_used()
	else:
		print("player未能够获取dirt_cursor_component")

#
#func on_plant_crop_used():
	#if crops_cursor_component:
		#if is_undo_use_tool_mode:
			#crops_cursor_component.on_undo_plant_crop_used()
		#else:
			#crops_cursor_component.on_plant_crop_used()
	#else:
		#print("player未能够获取crops_cursor_component")
