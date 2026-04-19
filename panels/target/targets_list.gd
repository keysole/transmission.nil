extends PopupBase

signal target_selected(target_data : TargetData)

const TARGET_BUTTON = preload('res://panels/target/target_button.tscn')


func clear_buttons() -> void:
	for b in %ButtonsContainer.get_children():
		b.queue_free()


func set_data(targets : Array[TargetData]) -> void:
	clear_buttons()
	
	for t in targets:
		var target_button = TARGET_BUTTON.instantiate()
		target_button.text = t.code_name + '-' + str(t.code_num)
		target_button.pressed.connect(_target_button_pressed.bind(t))
		%ButtonsContainer.add_child(target_button)


func _target_button_pressed(target_data : TargetData) -> void:
	target_selected.emit(target_data)
