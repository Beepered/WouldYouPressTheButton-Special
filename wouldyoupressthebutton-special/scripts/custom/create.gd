extends CanvasLayer

func _on_save_pressed() -> void:
	if($name.text):
		var path = "res://prompts/custom/" + $name.text + ".txt"
		var file = FileAccess.open(path,FileAccess.WRITE)
		file.store_string($prompts.text)
		file.close()
		$"..".create_item($name.text)
		$"saved message".visible = true
		await get_tree().create_timer(0.5).timeout
		$"saved message".visible = false
	else:
		$warning.visible = true
		await get_tree().create_timer(0.7).timeout
		$warning.visible = false

func _load_path(path):
	var file = FileAccess.open("res://prompts/custom/" + path + ".txt", FileAccess.READ)
	if(file):
		var content = file.get_as_text()
		$name.text = path
		$prompts.text = content
		file.close()
	else:
		print("can't find file")
