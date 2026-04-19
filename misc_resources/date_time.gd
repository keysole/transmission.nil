extends Button


func _process(delta: float) -> void:
	var hour_str = '%02d' % Game.hour
	var min_str = '%02d' % Game.min
	
	self.text = hour_str + ':' + min_str + ' | ' + str(Game.day) + '.' + str(Game.start_month) + '.' + str(Game.start_year)
