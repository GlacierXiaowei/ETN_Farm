class_name Player
extends CharacterBody2D

@export var current_tool: DataType.Tools = DataType.Tools.None

# 引用组件
@export var dirt_cursor_component: DirtCursorComponent 
@export var crops_cursor_component: CropsCursorComponent 

@onready var hit_componentt: HitComponent = $HitComponentt
@onready var tilling: NodeState = $StateMachine/Tilling
@onready var planting: NodeState = $StateMachine/Planting 

var player_direction: Vector2 = Vector2.ZERO
var is_undo_use_tool_mode: bool = false

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	
	GameInputEvent.player = self
	GameInputEvent.set_mode(GameInputEvent.current_mode)
	
	# --- 自动查找 DirtCursorComponent
	if !dirt_cursor_component:
		for child in self.get_children():
			if child is DirtCursorComponent:
				dirt_cursor_component = child
				break
		if get_parent():
			var comp = get_parent().get_node_or_null("DirtCursorComponent")
			if comp is DirtCursorComponent:
				dirt_cursor_component = comp
				
	if dirt_cursor_component:
		dirt_cursor_component.player = self
		# 注意：这里需要确保 Player0 场景下有 DirtPreview 节点，否则会报错
		if has_node("DirtPreview"):
			dirt_cursor_component.preview_sprite = get_node("DirtPreview")
			crops_cursor_component.preview_sprite = get_node("DirtPreview")
	
	# 自动查找 CropsCursorComponent ---
	if !crops_cursor_component:
		# 1. 先找自己的子节点
		for child in self.get_children():
			if child is CropsCursorComponent:
				crops_cursor_component = child
				break
		# 2. 如果没有，再找场景根节点下的 (TestScene)
		if !crops_cursor_component and get_parent():
			var comp = get_parent().get_node_or_null("CropsCursorComponent")
			if comp is CropsCursorComponent:
				crops_cursor_component = comp
	
	# 初始化 Crops 组件
	if crops_cursor_component:
		crops_cursor_component.player = self


	tilling.till_tool_used.connect(on_till_tool_used)
	planting.plant_tool_used.connect(on_plant_tool_used)


func on_tool_selected(tool: DataType.Tools) -> void:
	current_tool = tool
	hit_componentt.current_tool = tool
	print("Tool Selected: ", tool)

func _unhandled_input(event: InputEvent) -> void:
	for i in range(1, 10):
		if event.is_action_pressed("num_%d" % i):
			GameInputEvent.request_tool_select(i)
	
	if event.is_action_pressed("hit"):
		GameInputEvent.request_use_tool()
		
	if event.is_action_pressed("undo_hit"):
		GameInputEvent.request_undo_use_tool()


#func perform_hit_action() -> void:
	#match current_tool:
		#DataType.Tools.TillGround:
			#if dirt_cursor_component:
				#dirt_cursor_component.on_till_tool_used()
		#
		## 4. 种植逻辑移到这里
		#DataType.Tools.PlantCorn, DataType.Tools.PlantTomato:
			#if crops_cursor_component:
				#crops_cursor_component.on_plant_crop_used()
#
#func perform_undo_action() -> void:
	#match current_tool:
		#DataType.Tools.TillGround:
			#if dirt_cursor_component:
				#dirt_cursor_component.on_undo_till_tool_used()
		#
		## 5. 移除逻辑移到这里
		#DataType.Tools.PlantCorn, DataType.Tools.PlantTomato:
			#if crops_cursor_component:
				#crops_cursor_component.on_undo_plant_crop_used()

func perform_hit_action() -> void:
		match current_tool:
			DataType.Tools.TillGround:
				if dirt_cursor_component:
					dirt_cursor_component.on_till_tool_used()
				
			# 4. 种植逻辑移到这里
			DataType.Tools.PlantCorn, DataType.Tools.PlantTomato:
				if crops_cursor_component:
					crops_cursor_component.on_plant_crop_used()


func perform_undo_action() -> void:
		match current_tool:
			DataType.Tools.TillGround:
				if dirt_cursor_component:
				# 1. 先尝试移除该位置的作物 (如果有的话)
				# 我们直接借用 crops 组件的移除逻辑，因为它会自动计算坐标
					if crops_cursor_component:
						crops_cursor_component.on_undo_plant_crop_used()
					
					dirt_cursor_component.on_undo_till_tool_used()
				
				# 5. 移除逻辑移到这里
			DataType.Tools.PlantCorn, DataType.Tools.PlantTomato:
				if crops_cursor_component:
					crops_cursor_component.on_undo_plant_crop_used()

# 统一的工具行为回调 ---
func on_till_tool_used():
	# 根据当前是否是“撤销模式”分流
	if is_undo_use_tool_mode:
		perform_undo_action()
	else:
		perform_hit_action()

# 专门处理种植的回调
func on_plant_tool_used() -> void:
	if is_undo_use_tool_mode:
		
		perform_undo_action()
	else:
		perform_hit_action()
