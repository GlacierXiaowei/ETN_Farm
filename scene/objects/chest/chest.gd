extends Node2D

var balloon_preload = preload("res://dialog/game_dialog_balloon.tscn")

var corn_harvest_preload = preload("res://scene/objects/plant/corn_harvest.tscn")
var tomato_harvesr_preload = preload("res://scene/objects/plant/tomato_harvest.tscn")

@export var dialog_start_command : String
@export var food_drop_height: int = 40
@export var reward_output_radius : int =20
@export var output_reward_scenes: Array[PackedScene]

@onready var interactable_componetnt: InteractableCompenent = $InteractableComponetnt
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var feed_component: FeedComponent = $FeedComponent
@onready var reward_mark: Marker2D = $RewardMark
@onready var interactable_label_component: Control = $InteractableLabelComponent

var in_range: bool
var is_chest_open : bool



func _ready() -> void:
	interactable_componetnt.interactable_activated.connect(on_interactable_actived)
	interactable_componetnt.interactable_deactivated.connect(on_interactable_deactived)
	interactable_label_component.hide()
	
	DialogAction.on_feed_animal.connect(on_feed_animal)
	feed_component.food_received.connect(on_food_recieved)


func on_interactable_actived()->void:
	interactable_label_component.show()
	in_range=true


func on_interactable_deactived() -> void:
	interactable_label_component.hide()
	in_range=false
	if is_chest_open ==true:
		animated_sprite_2d.play("chest_close")
		is_chest_open = false
	
func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialog"):
			interactable_label_component.hide()
			animated_sprite_2d.play("chest_open")
			is_chest_open = true
			
			var balloon : BaseGameDialogBalloon = balloon_preload.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialog/conversation/chest.dialogue"),dialog_start_command)


func on_feed_animal()-> void:
	trigger_feed_harvest()
	trigger_feed_harvest("Tomato")


func trigger_feed_harvest(inventory_item:String ="Corn" ) -> void:
	if !in_range:
		return
	
	var inventory:Dictionary = InventoryManager.inventory
	
	if ! inventory.has(inventory_item):
		return
	
	var inventory_item_count: int= inventory[inventory_item]
	
	for index in inventory_item_count:
		var harvest_instance: Node2D = corn_harvest_preload.instantiate() as Node2D
		harvest_instance.global_position = Vector2(global_position.x , global_position.y - food_drop_height)
		get_tree().root.add_child(harvest_instance)
		var target_position = global_position
		
		var time_delay = randf_range(0.5,2.0)
		await  get_tree().create_timer(time_delay).timeout
		
		var tween = get_tree().create_tween()
		tween.tween_property(harvest_instance,"position",target_position,1.0)
		tween.tween_property(harvest_instance,"scale", Vector2(0.5,0.5),1.0)
		tween.tween_callback(harvest_instance.queue_free)
		
		InventoryManager.remove_collectable(inventory_item)



@warning_ignore("unused_parameter")
func on_food_recieved(area: Area2D) -> void:
	call_deferred("add_reward_scene")
	

func add_reward_scene() -> void:
	for scene in output_reward_scenes:
		var reward_scene: Node2D = scene.instantiate()
		var reward_position : Vector2 = get_random_position_in_circle(reward_mark.global_position,reward_output_radius)
		reward_scene.global_position = reward_position
		get_tree().root.add_child(reward_scene)

func get_random_position_in_circle(center: Vector2,radius:int) -> Vector2i:
	var angle = randf() * TAU
	
	var distance_from_center = sqrt(randf()) * radius
	
	var x: int = center.x + distance_from_center * cos(angle)
	var y: int = center.y + distance_from_center * cos(angle)
	
	return Vector2i(x,y)
