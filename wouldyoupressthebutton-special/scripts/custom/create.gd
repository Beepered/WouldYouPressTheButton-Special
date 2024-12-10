extends CanvasLayer

@onready var ideaText = $"idea/idea text"
var ideas = ["lemon", "skateboard"]
var ideaIndex = 0

func _on_save_pressed() -> void:
	if($name.text):
		var path = "res://prompts/" + $name.text
		var file = FileAccess.open(path,FileAccess.WRITE)
		file.store_string($prompts.text)
		file.close()
	else:
		$warning.visible = true
		await get_tree().create_timer(1.0).timeout
		$warning.visible = false

func _load_path(path):
	var file = FileAccess.open("res://prompts/" + path, FileAccess.READ)
	if(file):
		var content = file.get_as_text()
		$name.text = path
		$prompts.text = content

func _on_generate_idea_pressed() -> void:
	var newIdea = randi_range(0, ideas.size() - 1)
	while(ideaIndex == newIdea):
		newIdea = randi_range(0, ideas.size() - 1)
	ideaIndex = newIdea
	ideaText.text = ideas[ideaIndex]