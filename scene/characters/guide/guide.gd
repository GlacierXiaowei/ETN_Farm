extends Node

var balloon_scene = preload("res://dialog/game_dialog_balloon.tscn")

@onready var interactable_componetnt: InteractableCompenent = $InteractableComponetnt
@onready var interactable_label_component: Control = $InteractableLabelComponent

var dialog_able:bool =false


func _ready() -> void:
	interactable_label_component.hide()
	interactable_componetnt.interactable_activated.connect(on_interactable_activated)
	interactable_componetnt.interactable_deactivated.connect(on_interactable_deactivated)	



func on_interactable_activated()->void:
	interactable_label_component.show()
	dialog_able=true
	

func on_interactable_deactivated()->void:
	interactable_label_component.hide()
	dialog_able=false

func _unhandled_input(event: InputEvent) -> void:
	if !dialog_able:
		return
	if event.is_action_pressed("show_dialog"):
		var balloon : BaseGameDialogBalloon = balloon_scene.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(load("res://dialog/conversation/guide.dialogue"))
