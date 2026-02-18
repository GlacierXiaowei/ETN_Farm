extends PanelContainer
class_name ToolPanel

@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering_can: Button = $MarginContainer/HBoxContainer/ToolWateringCan
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato
@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

var tool_button_group: ButtonGroup = ButtonGroup.new()
var slot_buttons: Array[Button] = []

func _ready() -> void:
	for button in h_box_container.get_children():
		if button is Button:
			button.button_group = tool_button_group
			##godot引擎不能够分辨不同设备源的信号（比如键盘和手柄）
			##所以 我干脆先断绝后患 之后再打手柄补丁
			button.focus_mode=Control.FOCUS_NONE
			button.pressed.connect(on_button_pressed.bind(button))
			slot_buttons.append(button)
	
	

func on_button_pressed(button:Button) -> void:
	var tool_name: String = button.get_meta("Tool_Name")
	if DataType.Tools[tool_name]==ToolManager.selected_tool:
		ToolManager.select_tool(DataType.Tools.None)
		GameInputEvent.clear_use_tool_request()
		return
	ToolManager.select_tool(DataType.Tools[tool_name])
	##切换工具时会重新计数 算是修复bug?
	GameInputEvent.clear_use_tool_request()
	
func _process(_delta: float) -> void:
	var slot := GameInputEvent.use_tool_select()
	if slot != -1:
		select_tool_by_slot(slot)
	else:
		##当不在游戏模式 直接禁用 免得招惹是非
		set_button_disable(false)
		
func select_tool_by_slot(slot: int) -> void:
	##该函数逻辑是 让按钮被“按下”
	if slot < 0 or slot >= slot_buttons.size():
		return
	var button := slot_buttons[slot-1]
	## 如果按钮本身不可用，直接忽略
	if button.disabled:
		return

	##在Godot4.0版本下 下列语法和鼠标点击 本质一样
	##鼠标点击 本质就是改变下列参数 因此 反应一模一样
	button.button_pressed = true

func set_button_disable(is_in_gameplay: bool ) ->void:
	for button in slot_buttons:
		button.disabled=is_in_gameplay
