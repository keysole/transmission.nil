class_name TargetDataPanel
extends PopupBase

const FREQUENCY_BAR = preload('res://panels/target/frequency_bar.tscn')
const FREQUENCY_STEP = 5

func clear_container() -> void:
	for f in %FrequencyContainer.get_children():
		f.queue_free()


func set_frequency_data(target_data : TargetData, frequency_start : int) -> void:
	clear_container()
	
	%TargetLabel.text = target_data.code_name + '-' + str(target_data.code_num)
	
	var count = (World.current_max_freq - World.current_min_freq) / FREQUENCY_STEP + 1
	
	var current_frequency = World.current_min_freq
	for i in range(count):
		var power = target_data.frequencies.get(current_frequency, 0)
		var frequency_bar = FREQUENCY_BAR.instantiate()
		frequency_bar.set_data(current_frequency, power)
		%FrequencyContainer.add_child(frequency_bar)
		
		current_frequency += FREQUENCY_STEP
		
