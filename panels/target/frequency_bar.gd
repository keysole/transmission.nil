class_name FrequencyBar
extends VBoxContainer


@export var max_height := 500.0


func set_data(frequency : int, strength : int) -> void:
	$Label.text = str(frequency)
	
	var height_coeff = clamp(strength / 10.0, 0.01, 1.0)
	$TextureRect.custom_minimum_size.y = height_coeff * max_height
