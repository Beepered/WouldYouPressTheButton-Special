extends CanvasLayer

func _on_play_again_pressed() -> void:
	$"../Discussion"._ready()


func _on_backto_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
