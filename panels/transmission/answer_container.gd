class_name AnswerContainer
extends HBoxContainer


func get_answer() -> String:
	return %NameEdit.text.to_upper() + %NumEdit.text
