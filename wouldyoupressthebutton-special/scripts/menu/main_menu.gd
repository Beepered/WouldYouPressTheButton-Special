extends Node2D

@onready var playerNames = $Settings/NumPlayers/ScrollContainer/VBoxContainer.get_children()

@onready var mainMenu = $Menu

func _ready() -> void:
	$Menu.visible = true;
	$Settings.visible = false;
	$Instructions.visible = false;
	$Credits.visible = false;

func _process(_delta: float) -> void:
	$"Settings/DiscussionTime/time text".text = str(Global.discussTime)
	$"Settings/VotingTime/time text".text = str(Global.voteTime)
	if(checkNumPlayers() >= 5):
		$Settings/PlayButton.disabled = false
	else:
		$Settings/PlayButton.disabled = true

func _on_setting_button_button_down() -> void:
	mainMenu.visible = false
	$Settings.visible = true;

func _on_credits_button_down() -> void:
	mainMenu.visible = false
	$Credits.visible = true;
	

func _on_instructions_button_down() -> void:
	mainMenu.visible = false
	$Instructions.visible = true;

	
func _on_back_button_button_down() -> void:
	mainMenu.visible = true
	$Settings.visible = false;
	$Credits.visible = false;
	$Instructions.visible = false;

func _on_play_button_button_down() -> void:
	for player_name in playerNames:
		if(player_name.text != ""):
			Global.playerNames.push_back(player_name.text)
	get_tree().change_scene_to_file("res://scenes/PlayScene.tscn")

@onready var warning = $Settings/NumPlayers/Warning
func checkNumPlayers():
	var count = 0
	var nameList = []
	for player_name in playerNames:
		var name = player_name.text
		if(name != ""):
			if nameList.has(name):
				warning.visible = true
				return 0
			count += 1
		nameList.append(name)
	warning.visible = false
	return count
