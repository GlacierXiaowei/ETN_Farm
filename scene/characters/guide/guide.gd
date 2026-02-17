extends Node

@onready var interactable_componetnt: InteractableCompenent = $InteractableComponetnt
@onready var interactable_label_component: Control = $InteractableLabelComponent

func _ready() -> void:
	interactable_label_component.hide()
	interactable_componetnt.interactable_activated.connect(on_interactable_activated)
	interactable_componetnt.interactable_deactivated.connect(on_interactable_deactivated)	



func on_interactable_activated()->void:
	interactable_label_component.show()


func on_interactable_deactivated()->void:
	interactable_label_component.hide()
