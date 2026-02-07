class_name GameInputEvent
#这里使用静态是因为 这个不像别的OOP
#注册类名并不意味着它会被加载 对于非静态函数
#需要管理生命周期 需要实例化（或者autuload）
#但是对于静态函数 就像C++oop的类一样 可以直接访问成员
##耦合 game_input_context


##角色输入/状态管理 
##用于管理 角色的 _unhandled_input 
##由于状态机调用该脚本的函数 并且输入请求来源于 player 的_unhandled_input
##因此该方法的可以完全禁用游戏输入 以让UI的输入无法传递到player
##注意大小写 Player是一个类 控制的是Player的东西 这个小写的是使用的具体节点
##signal mode_is_set(mode : GameInputEvent.Mode)信号依赖实例 静态函数不可以发出
enum Mode {
	GAMEPLAY,
	UI,
	CUTSCENE,
	DISABLED
}
##享有默认值 出现bug再更改 免得人物动不了
static var current_mode: Mode = Mode.GAMEPLAY
static var player: Player = null
static func set_mode(mode: Mode) -> void:
	current_mode = mode

	if player:
		player.set_process_unhandled_input(mode == Mode.GAMEPLAY)
	
	

##角色移动管理
static var direction: Vector2
static func movement_input() -> Vector2:
	var dir := Vector2.ZERO
	if current_mode!=GameInputEvent.Mode.GAMEPLAY:
		return dir

	if Input.is_action_pressed("walk_left"):
		dir.x -= 1
	if Input.is_action_pressed("walk_right"):
		dir.x += 1
	if Input.is_action_pressed("walk_up"):
		dir.y -= 1
	if Input.is_action_pressed("walk_down"):
		dir.y += 1

	return dir.normalized()
static func is_movement_input() -> bool:
	return movement_input() != Vector2.ZERO



##工具使用管理（防止在更换工具的时候 触发hit）
##保存 使用工具的请求
static var _use_tool_requested:bool 
##_unhandled_input函数放置在player身上 只有player存在的时候才能够处理这些需求
static func request_use_tool() -> void:
	##解耦合 用于处理 使用工具意图的请求
	_use_tool_requested = true
static func use_tool() -> bool:
	##该函数是 只是被（状态机）请求 并消耗
	#var use_tool_value: bool = Input.is_action_pressed("hit") and GameInputEvent.current_mode==GameInputEvent.Mode.GAMEPLAY

	#return use_tool_value
	if _use_tool_requested:
		_use_tool_requested = false  # ← 消耗掉这次输入
		return true
	else:
		return false
static func is_use_tool_request() -> bool:
	##查询 当前是否缓存了请求
	return _use_tool_requested
static func clear_use_tool_request() -> void:
	_use_tool_requested=false
	


## 支持快捷键的工具选择请求
##代码中 request_tool_select 在player中的_unhandled_input中设置
##因此 和 我们的左键共享控制（因为在同一个函数内部）
static var _tool_select_requested : int = -1
static func request_tool_select(slot_index: int) -> void:
	_tool_select_requested = slot_index
static func use_tool_select() -> int:
	if _tool_select_requested != -1:
		var slot := _tool_select_requested
		_tool_select_requested = -1
		return slot
	return -1
