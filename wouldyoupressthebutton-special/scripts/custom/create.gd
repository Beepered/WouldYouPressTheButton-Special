extends CanvasLayer

var creating = false

func _on_save_pressed() -> void:
	if($name.text):
		var path = Global.custom_folder_path + $name.text + ".txt"
		if(!FileAccess.open(path, FileAccess.READ)): # if file didn't exist
			$"..".create_item($name.text)
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string($prompts.text)
		file.close()
		
		$"saved message".visible = true
		await get_tree().create_timer(0.7).timeout
		$"saved message".visible = false
	else:
		$warning.visible = true
		await get_tree().create_timer(0.7).timeout
		$warning.visible = false

func _load_path(path):
	var file = FileAccess.open(Global.custom_folder_path + path + ".txt", FileAccess.READ)
	if(file):
		var content = file.get_as_text()
		$name.text = path
		$prompts.text = content
		file.close()
	else:
		print("Create TXT: can't find file: ", file)
		$name.text = ""
		$prompts.text = ""

func _on_name_text_changed(new_text: String) -> void:
	var path = Global.custom_folder_path + new_text + ".txt"
	if(creating && FileAccess.open(path, FileAccess.READ) || new_text == "default"): # if file didn't exist
		$"name exists".visible = true
		$save.disabled = true
	else:
		$"name exists".visible = false
		$save.disabled = false
