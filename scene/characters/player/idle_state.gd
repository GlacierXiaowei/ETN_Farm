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
	GameInputEvent.movement_input()
	#↑ 注意 这里应该先获取movement数据 执行这个函数之后 is__函数的direction才会被更新
	#↑和虚幻/unity一样遵循先获取数据 在进行判断哦
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
		
	#if  player.current_tool==DataType.Tools.PlantCorn && GameInputEvent.is_undo_use_tool_request():
		#transition.emit("PlantCorn")
		#return
	#if  player.current_tool==DataType.Tools.PlantCorn && GameInputEvent.is_use_tool_request():
		#transition.emit("PlantCorn")
		#return
		#
	#if  player.current_tool==DataType.Tools.PlantTomato && GameInputEvent.is_undo_use_tool_request():
		#transition.emit("PlantTomato")
		#return
	#if  player.current_tool==DataType.Tools.PlantCorn && GameInputEvent.is_use_tool_request():
		#transition.emit("PlantTomato")
		#return



	if GameInputEvent.is_movement_input():
		transition.emit("Walking")
		return


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	#animated_sprite_2d.stop()
	pass
	
