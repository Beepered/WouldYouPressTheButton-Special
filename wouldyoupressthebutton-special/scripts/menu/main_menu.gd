extends Node2D

@onready var playerNames = [$CanvasLayer/Settings/NumPlayers/Line, $CanvasLayer/Settings/NumPlayers/Line2, $CanvasLayer/Settings/NumPlayers/Line3,
$CanvasLayer/Settings/NumPlayers/Line4, $CanvasLayer/Settings/NumPlayers/Line5, $CanvasLayer/Settings/NumPlayers/Line6,
$CanvasLayer/Settings/NumPlayers/Line7, $CanvasLayer/Settings/NumPlayers/Line8]

func _ready() -> void:
	$CanvasLayer.visible = true;
	$CanvasLayer/Settings.visible = false;

func _process(_delta: float) -> void:
	$CanvasLayer/Settings/Rounds/num.text = str(Global.numRounds)
	$"CanvasLayer/Settings/DiscussionTime/time text".text = str(Global.discussTime)
	$"CanvasLayer/Settings/VotingTime/time text".text = str(Global.voteTime)
	if(checkNumPlayers() >= 5):
		$CanvasLayer/Settings/PlayButton.disabled = false
	else:
		$CanvasLayer/Settings/PlayButton.disabled = true

func _on_setting_button_button_down() -> void:
	$CanvasLayer/Settings.visible = true;

func _on_button_button_down() -> void:
	$CanvasLayer/Settings.visible = false;

func _on_credits_button_down() -> void:
	$CanvasLayer/Credits.visible = true;

func _on_back_button_down() -> void:
	$CanvasLayer/Credits.visible = false;

func _on_play_button_button_down() -> void:
	for player_name in playerNames:
		if(player_name.text != ""):
			Global.playerNames.push_back(player_name.text)
	get_tree().change_scene_to_file("res://scenes/PlayScene.tscn")

func checkNumPlayers(): # doesn't check if names are different if you want to do that
	var count = 0
	for player_name in playerNames:
		if(player_name.text != ""):
			count += 1
	return count
