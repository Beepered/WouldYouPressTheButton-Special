extends Node2D

signal beginPlay

@onready var playerNames = $Settings/NumPlayers/ScrollContainer/VBoxContainer.get_children()

@onready var mainMenu = $Menu
@onready var settings = $Settings
@onready var instructions = $Instructions
@onready var credits = $Credits

func _ready() -> void:
	mainMenu.visible = true;
	settings.visible = false;
	instructions.visible = false;
	credits.visible = false;

func _process(_delta: float) -> void:
	$"Settings/DiscussionTime/time text".text = str(Global.discussTime)
	$"Settings/VotingTime/time text".text = str(Global.voteTime)
	if(checkNumPlayers() >= 5):
		$Settings/PlayButton.disabled = false
	else:
		$Settings/PlayButton.disabled = true

func _on_setting_button_button_down() -> void:
	mainMenu.visible = false
	settings.visible = true;

func _on_credits_button_down() -> void:
	mainMenu.visible = false
	credits.visible = true;

func _on_instructions_button_down() -> void:
	mainMenu.visible = false
	instructions.visible = true;

func _on_back_button_button_down() -> void:
	mainMenu.visible = true
	settings.visible = false;
	credits.visible = false;
	instructions.visible = false;

func _on_play_button_button_down() -> void:
	for player_name in playerNames:
		if(player_name.text != ""):
			Global.playerNames.push_back(player_name.text)
	beginPlay.emit()

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
