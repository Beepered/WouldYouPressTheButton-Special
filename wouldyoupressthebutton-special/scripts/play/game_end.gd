extends CanvasLayer

signal beginMenu

func _on_play_again_pressed() -> void:
	$"../Discussion"._ready()

func _on_backto_menu_pressed() -> void:
	$"..".beginMenu.emit()
