extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	pass


func _on_next_transitions() -> void:
	if !animated_sprite_2d.is_playing():
		transition.emit("idle")


func _on_enter() -> void:
	GameInputEvent.use_tool()
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("watering_back")
		Vector2.DOWN:
			animated_sprite_2d.play("watering_front")
		Vector2.LEFT:
			animated_sprite_2d.play("watering_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("watering_right")
		Vector2.ZERO:
			animated_sprite_2d.play("watering_front")


func _on_exit() -> void:
	#animated_sprite_2d.stop()
	pass
