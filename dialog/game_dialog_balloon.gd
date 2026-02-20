extends BaseGameDialogBalloon

@onready var emote_panel: Panel = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/EmotePanel

func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	super.start(with_dialogue_resource, title, extra_game_states)
	emote_panel.play_emote("emote_12_talking")


func next(next_id: String) -> void:
	super.next(next_id)
	emote_panel.play_emote("emote_12_talking")
