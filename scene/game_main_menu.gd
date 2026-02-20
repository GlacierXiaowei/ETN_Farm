extends CanvasLayer
@onready var save: Button = $MarginContainer/VBoxContainer/Save


func _ready() -> void:
	save.disabled = not SaveGameManager.allow_save_game


func _on_start_pressed() -> void:
	GameManager.start_game()
	save.disabled = false
	self.queue_free()
	
func _on_save_pressed() -> void:
	SaveGameManager.save_game()


func _on_exit_pressed() -> void:
	GameManager.exit_game()
