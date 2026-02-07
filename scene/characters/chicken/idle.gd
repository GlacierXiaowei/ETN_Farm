extends NodeState

@export var character: CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
##interval 的释意为 时间上的间隔、间隙
@export var idle_state_time_interval: float =5.0

@onready var idle_state_timer: Timer = Timer.new()

var idle_state_timeout: bool = false

func _ready() -> void:
	idle_state_timer.wait_time = idle_state_time_interval
	idle_state_timer.timeout.connect(on_idle_state_timer_timeout)
	##注意 timer 是一个节点 需要添加到场景树之后 才可以正常进行逻辑
	##神名周期和父节点绑定 可以不手动 queue_free (Godot不建议使用free 而是使用queue_free)
	add_child(idle_state_timer)


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	pass


##这个函数 是父类的物理帧中 不停调用的哈
func _on_next_transitions() -> void:
	if idle_state_timeout:
		transition.emit("walk")


func _on_enter() -> void:
	animated_sprite_2d.play("idle")
	idle_state_timeout=false
	idle_state_timer.start()


func _on_exit() -> void:
	animated_sprite_2d.stop()

func on_idle_state_timer_timeout() ->void:
	idle_state_timeout = true
