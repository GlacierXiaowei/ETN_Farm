extends Control

@onready var day_label: Label = $DayPanel/MarginContainer/DayLabel
@onready var time_label: Label = $TimePanel/MarginContainer/TimeLabel

@export var normal_speed: int = 5
@export var fast_speed: int = 100
@export var super_fast_speed : int = 500


func _ready() -> void:
	DayNightManager.time_tick.connect(on_time_tick)
	
	
func on_time_tick(day: int , hour: int , minute : int)-> void:
	day_label.text = "Day " + str(day)
	time_label.text= "%02d:%02d" % [hour,minute]
	
	
func _on_normal_pressed() -> void:
	DayNightManager.game_speed = normal_speed


func _on_fast_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DayNightManager.game_speed = fast_speed
	else:
		DayNightManager.game_speed = normal_speed
		
		
func _on_super_fast_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DayNightManager.game_speed = super_fast_speed
	else:
		DayNightManager.game_speed = normal_speed
