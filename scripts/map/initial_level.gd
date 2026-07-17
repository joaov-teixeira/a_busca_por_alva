extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box = $DialogueBox

var dialogue_active: bool = false


func _ready() -> void:
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	await get_tree().process_frame

	connect_dialogue_triggers()


func connect_dialogue_triggers() -> void:
	var triggers: Array[Node] = get_tree().get_nodes_in_group(
		"dialogue_triggers"
	)

	for trigger in triggers:
		if trigger.has_signal("dialogue_requested"):
			if not trigger.dialogue_requested.is_connected(
				_on_dialogue_requested
			):
				trigger.dialogue_requested.connect(
					_on_dialogue_requested
				)


func _on_dialogue_requested(lines: Array) -> void:
	if dialogue_active:
		return

	dialogue_active = true
	player.set_can_move(false)

	dialogue_box.start_dialogue(lines)


func _on_dialogue_finished() -> void:
	dialogue_active = false
	player.set_can_move(true)
