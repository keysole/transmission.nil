extends LineEdit

@export var only_numbers := false
var current_text : String

func _ready() -> void:
	self.text_changed.connect(_text_changed)


func _text_changed(_text : String) -> void:
	print(caret_column)
	if !only_numbers:
		current_text = _text
		self.text = _text
	else:
		if _text.is_empty() or _text.is_valid_int():
			current_text = _text
			self.text = _text
		else:
			self.text = current_text

	#if text.length() == 0:
	#	%LineEdit.add_theme_font_override(&'font', FONT_ITALIC)
	#else:
	#	%LineEdit.add_theme_font_override(&'font', FONT_MAIN)
