extends NodeState
#↑这个继承自script里面的那个脚本
#因为那个脚本已经注册了这个类
#以下函数为多态 信号已经是该脚本的成员 但是由于信号不能重载 所以信号那一行已经删掉

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	#↓ 语法解释 和switch 相同且更智能，不需要
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("idle_back")
		Vector2.DOWN:
			animated_sprite_2d.play("idle_front")
		Vector2.LEFT:
			animated_sprite_2d.play("idle_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("idle_right")
		Vector2.ZERO:
			animated_sprite_2d.play("idle_front")


func _on_next_transitions() -> void:
	player.movement_input()
	#↑ 注意 这里应该先获取movement数据 执行这个函数之后 is_函数的direction才会被更新
	#↑先获取数据 在进行判断
	if  player.current_tool==DataType.Tools.AxeWood && GameInputEvent.is_use_tool_request():
		transition.emit("Chopping")
		return
		
	if  player.current_tool==DataType.Tools.TillGround && GameInputEvent.is_undo_use_tool_request():
		transition.emit("Tilling")
		return	
	if  player.current_tool==DataType.Tools.TillGround && GameInputEvent.is_use_tool_request():
		transition.emit("Tilling")
		return

		
	if  player.current_tool==DataType.Tools.WaterCrops && GameInputEvent.is_use_tool_request():
		transition.emit("Watering")
		return
	
	## 分支 B: 如果是作物种子 -> 切换到 Planting 状态 (新增逻辑)
	##由于 在这个时候 撤销和正常的 目前信号上没有区别 而是在player的节点获取点击的时候 就给标记了 所以我二合一
	if GameInputEvent.is_use_tool_request() or GameInputEvent.is_undo_use_tool_request():
		if player.current_tool == DataType.Tools.PlantCorn or player.current_tool == DataType.Tools.PlantTomato:
			transition.emit("Planting")
			return
		
	if player.is_movement_input():
		transition.emit("Walking")
		return


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	#animated_sprite_2d.stop()
	pass
	
