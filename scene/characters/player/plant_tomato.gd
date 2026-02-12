extends NodeState

@export var player: Player

signal tomato_planted_used


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	pass


func _on_next_transitions() -> void:
	pass #让on_enter 执行完就emit就行



func _on_enter() -> void:
	##注意 真的是返回bool值的
	if GameInputEvent.use_tool():
		player.is_undo_use_tool_mode = false

	if GameInputEvent.undo_use_tool():
		player.is_undo_use_tool_mode = true

	##种植和取消 统一使用该信号
	tomato_planted_used.emit()
	
	transition.emit("idle")


func _on_exit() -> void:
	pass
