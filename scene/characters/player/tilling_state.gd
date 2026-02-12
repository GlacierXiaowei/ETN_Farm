extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

##"""
##很遗憾 咱们的使用工具的代码结构不同 为了能够正常耕地
##我们使用工具在这个节点之下 因此 为了能够正常传递给player的子节点
##使用信号回调 告知player 咱们工具已经使用了 
##考虑到 该节点的父节点会在别的地方重用的问题
##这个信号由该节点直接发出 只属于 这个节点
##"""
signal till_tool_used


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	pass


func _on_next_transitions() -> void:
	if !animated_sprite_2d.is_playing():
		transition.emit("idle")


func _on_enter() -> void:
	##注意 真的是返回bool值的
	if GameInputEvent.use_tool():
		player.is_undo_use_tool_mode = false

	if GameInputEvent.undo_use_tool():
		player.is_undo_use_tool_mode = true

	GameInputEvent.use_tool()
	GameInputEvent.undo_use_tool()
	till_tool_used.emit()
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


func _on_exit() -> void:
	#animated_sprite_2d.stop()
	pass
