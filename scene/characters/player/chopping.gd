extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var hit_component_collision_shape: CollisionShape2D
@onready var hit_component : HitComponent = $"../../HitComponentt"

func _ready() -> void:
	hit_component_collision_shape.disabled = true
	hit_component_collision_shape.position = Vector2(0,0)

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
			animated_sprite_2d.play("chopping_back")
			hit_component_collision_shape.position = Vector2(0,-18)
		Vector2.DOWN:
			animated_sprite_2d.play("chopping_front")
			hit_component_collision_shape.position = Vector2(0,3)
		Vector2.LEFT:
			animated_sprite_2d.play("chopping_left")
			hit_component_collision_shape.position = Vector2(-9,0)
		Vector2.RIGHT:
			animated_sprite_2d.play("chopping_right")
			hit_component_collision_shape.position = Vector2(9,0)
		Vector2.ZERO:
			animated_sprite_2d.play("chopping_front")
			hit_component_collision_shape.position = Vector2(0,3)
	
	hit_component.current_tool=DataType.Tools.AxeWood
	await get_tree().create_timer(0.33).timeout
	hit_component_collision_shape.disabled = false

func _on_exit() -> void:
	#我解释一下 这里不要使用stop 
	#因为强行stop引擎会默认切回chopping第一帧 
	#导致闪一下第一帧 再是切回idle
	#即使是循环动画 在用play切换到另一个动画的时候 也会直接断掉先前的动画 
	#并且不会右什么闪最后一帧的问题
	#所以gpt就说 不必也不应该在状态转换的时候 使用stop
	#animated_sprite_2d.stop()
	hit_component_collision_shape.disabled = true
	hit_component.current_tool=DataType.Tools.None
	
