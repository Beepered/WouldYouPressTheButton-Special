extends CanvasLayer

func _process(_delta: float) -> void:
	$"DiscussionTime/time text".text = str(Global.discussTime)
	$"VotingTime/time text".text = str(Global.voteTime)
	if(checkNumPlayers() >= 5):
		$PlayButton.disabled = false
	else:
		$PlayButton.disabled = true

@onready var playerNames = $NumPlayers/ScrollContainer/VBoxContainer.get_children()
@onready var warning = $NumPlayers/Warning
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

func fill_custom_container():
	var dir = DirAccess.open(Global.custom_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				var b = Button.new()
				var shortName = file_name.substr(0, file_name.find(".txt"))
				b.text = shortName
				b.set_custom_minimum_size(Vector2(270, 30))
				b.pressed.connect(set_prompt_choice.bind(shortName))
				$UseCustom/ScrollContainer/VBoxContainer.add_child(b)
			file_name = dir.get_next()

func set_prompt_choice(path):
	Global.file_path = path
	$"UseCustom/choice name".text = path

func _on_choose_default_pressed() -> void:
	Global.file_path = "default"
	$"UseCustom/choice name".text = "default"

func _on_play_button_button_down() -> void:
	for player_name in playerNames:
		if(player_name.text != ""):
			Global.playerNames.push_back(player_name.text)
	$"..".beginPlay.emit()
