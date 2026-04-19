extends Panel

signal requested_transmission(ans : Array[String])

const ANSWER_CONTAINER = preload('res://panels/transmission/answer_container.tscn')


func _ready() -> void:
	%TransmitButton.pressed.connect(_transmit_pressed)


func _transmit_pressed() -> void:
	%ButtonSfx.play()
	var answer = get_answer()
	
	requested_transmission.emit(answer)


func set_active(active : bool) -> void:
	%TransmitButton.disabled = !active


func get_answer() -> Array[String]:
	var answer : Array[String]
	for ans_con : AnswerContainer in %AnswersContainer.get_children():
		answer.append(ans_con.get_answer())

	return answer


func set_answer_containers(count : int) -> void:
	for ans_cont in %AnswersContainer.get_children():
		ans_cont.queue_free()
		
	
	for i in range(count):
		var ans_cont = ANSWER_CONTAINER.instantiate()
		%AnswersContainer.add_child(ans_cont)
