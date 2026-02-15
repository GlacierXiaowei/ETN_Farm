extends StaticBody2D

##按住 shift+ctrl 鼠标拖动 就可以一键设置为 @onready 这种
@onready var interactable_componetnt: InteractableCompenent = $InteractableComponetnt
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D =$AnimatedSprite2D


func _ready() -> void:
	interactable_componetnt.interactable_activated.connect(on_interactable_activated)
	interactable_componetnt.interactable_deactivated.connect(on_interactable_deactivated)
	self.collision_layer = 1
	
	
func on_interactable_activated() -> void:
	animated_sprite_2d.play("open_door")
	#和玩家同为2蹭（player）以关闭碰撞
	self.collision_layer = 2
	#print("门已激活")
	
func on_interactable_deactivated() -> void:
	animated_sprite_2d.play("close_door")
	self.collision_layer = 1
	#print("门停止激活")
