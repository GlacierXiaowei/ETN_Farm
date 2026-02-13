extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

##官方的平滑移动物理参数 acceleration 为加速度 他和friction的单位是像素每秒平方 
##实际时需要乘以delta 变成px/s
##注意 在Godot2D中 player.velocity表示px/s （就是本身速度的单位哈）
##friction 是摩擦力 即松开方向键后 速度衰减为 800px 每秒
@export var max_speed := 125.0
@export var acceleration := 850.0
@export var friction := 550.0


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(delta: float) -> void:
	##支持走路的时候急停使用工具
	if GameInputEvent.is_use_tool_request():
		player.velocity=Vector2.ZERO
		transition.emit("idle")
		return
	
	##当动画正在播放的时候 使用play 不会产生实际影响 可以放心
	## --- 动画（只看朝向，不看输入） ---
	var face_dir := player.player_direction

	if abs(face_dir.x) > abs(face_dir.y):
		if face_dir.x > 0:
			animated_sprite_2d.play("walking_right")
		else:
			animated_sprite_2d.play("walking_left")
	else:
		if face_dir.y > 0:
			animated_sprite_2d.play("walking_front")
		else:
			animated_sprite_2d.play("walking_back")
	
	##更换为GODOT官方的 顺滑物理方案
	##movetoward（Vector2 a,float b） 也就是 最终速度为a
	##基于当前的速度 但是最多变化 b 的量 所以每一帧都会增加b(因为代码成了delta)
	##并且限制最大值为 a
	##dir就是 direction
	var dir := GameInputEvent.movement_input()
	if dir != Vector2.ZERO:
		player.velocity = player.velocity.move_toward(
			dir * max_speed,
			acceleration * delta
		)
		player.player_direction = dir
	else:
		player.velocity = player.velocity.move_toward(
			Vector2.ZERO,
			friction * delta
		)
	player.move_and_slide()
	

##不需要使用GameInputEvent.movement_input()
##代码优化之后 is_movement_input在调用的时候 就会调用一次 movement_input 
func _on_next_transitions() -> void:
	#GameInputEvent.movement_input()
	#if !GameInputEvent.is_movement_input():
	if player.velocity.length() <= 1.0 :
		transition.emit("idle")
		GameInputEvent.movement_input()
	##↑ 注意 这里应该先获取movement数据 执行这个函数之后 is__函数的direction才会被更新
	##↑和虚幻/unity一样遵循先获取数据 在进行判断哦
	#if  player.current_tool==DataType.Tools.AxeWood && GameInputEvent.is_use_tool():
		#transition.emit("Chopping")
	#if  player.current_tool==DataType.Tools.TillGround && GameInputEvent.use_tool():
		#transition.emit("Tilling")
	#if  player.current_tool==DataType.Tools.WaterCrops && GameInputEvent.use_tool():
		#transition.emit("Watering")
	
	
	#if GameInputEvent.is_movement_input():
		#transition.emit("Walking")


func _on_enter() -> void:
	pass
	
	
func _on_exit() -> void:
	animated_sprite_2d.stop()
	pass
