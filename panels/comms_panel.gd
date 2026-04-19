extends Panel

@export var text_speed := 20.0


func _ready() -> void:
	%TextTimer.timeout.connect(_text_sfx_timeout)


func show_current_description() -> void:
	%StatusLabel.hide()
	%DescriptionLabel.show()


func show_answer_status_text(comm : CommsData, correct : bool) -> void:
	%DescriptionLabel.hide()
	
	%StatusLabel.show()
	%StatusLabel.text = comm.correct_text if correct else comm.incorrect_text
	%StatusLabel.visible_characters = 0
	
	var tween = create_tween()
	var text_time = %StatusLabel.get_parsed_text().length() / text_speed
	%TextTimer.start()
	
	tween.tween_property(%StatusLabel, ^'visible_ratio', 1.0, text_time)
	
	await tween.finished
	%TextTimer.stop()
	await get_tree().create_timer(1.0).timeout

	return


func show_mission_text(comm : CommsData) -> void:
	%DescriptionLabel.hide()
	
	%StatusLabel.show()
	%StatusLabel.text = comm.status_text
	%StatusLabel.visible_characters = 0
	
	var tween = create_tween()
	var text_time = %StatusLabel.get_parsed_text().length() / text_speed
	%TextTimer.start()

	tween.tween_property(%StatusLabel, ^'visible_ratio', 1.0, text_time)
	
	await tween.finished
	%TextTimer.stop()

	await get_tree().create_timer(1.0).timeout
	
	%StatusLabel.hide()
	%DescriptionLabel.show()
	%DescriptionLabel.text = comm.description_text
	%DescriptionLabel.visible_characters = 0
	
	tween = create_tween()
	text_time = %DescriptionLabel.get_parsed_text().length() / text_speed
	tween.tween_property(%DescriptionLabel, ^'visible_ratio', 1.0, text_time)
	%TextTimer.start()

	
	await tween.finished
	%TextTimer.stop()

	
	return


func _text_sfx_timeout() -> void:
	%TextSfx.play()
