extends AudioStreamPlayer


func _ready() -> void:
	configure_loop()

	if not playing:
		play()


func configure_loop() -> void:
	if stream == null:
		push_warning("Nenhuma música foi configurada no MusicManager.")
		return

	if stream is AudioStreamOggVorbis:
		stream.loop = true

	elif stream is AudioStreamMP3:
		stream.loop = true

	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
