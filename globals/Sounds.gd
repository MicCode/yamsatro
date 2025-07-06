extends Node

func click():
	SoundPlayer.play_sfx("rolls/roll-stop-6.wav", {pitch = 1.0, pitch_variation = 0.05})

func roll():
	SoundPlayer.play_sfx(_one_of("rolls/roll", 3), {pitch = 0.7, pitch_variation = 0.2, start_delay_variation_ms = 500.0})

func finish_roll():
	SoundPlayer.play_sfx(_one_of("rolls/roll-stop", 6), {pitch = 0.8, pitch_variation = 0.1})
	
func tada():
	SoundPlayer.play_sfx("tada.wav", {volume = -6.0})


func _one_of(base_name: String, n: int) -> String:
	return base_name + "-" + str(randi_range(1, n)) + ".wav"
