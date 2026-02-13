extends NodeState
class_name Planting

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

# 信号：通知 Player 执行具体的种植操作（生成节点）
signal plant_tool_used 

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	pass

func _on_next_transitions() -> void:
	# 退出条件：当动画播放完毕，自动回到 Idle
	if !animated_sprite_2d.is_playing():
		transition.emit("Idle")

func _on_enter() -> void:
	if GameInputEvent.is_undo_use_tool_request():
		player.is_undo_use_tool_mode = true
		print("[调试-Planting] 检测到撤销操作，已通知 Player")
	else:
		player.is_undo_use_tool_mode = false
		print("[调试-Planting] 检测到种植操作，已通知 Player")
	
	GameInputEvent.undo_use_tool()
	GameInputEvent.use_tool()
	print("[调试-PlantingState] 已消耗输入请求 (use_tool = false)")
	
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("tilling_back")
		Vector2.DOWN:
			animated_sprite_2d.play("tilling_front")
		Vector2.LEFT:
			animated_sprite_2d.play("tilling_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("tilling_right")
		Vector2.ZERO:
			animated_sprite_2d.play("tilling_front")
	
	print("[调试-PlantingState] 发射 plant_tool_used 信号...")
	# 3. 通知 Player (指挥官) 执行种植逻辑
	plant_tool_used.emit()

func _on_exit() -> void:
	#animated_sprite_2d.stop()
	pass
