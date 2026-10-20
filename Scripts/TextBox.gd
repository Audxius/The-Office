extends CanvasLayer

@onready var text_box_container: MarginContainer = $TextBoxContainer
@onready var spoken_text: Label = $TextBoxContainer/TextureRect/MarginContainer/VBoxContainer/SpokenText
@onready var character_name: Label = $TextBoxContainer/TextureRect/MarginContainer/VBoxContainer/CharacterName
@onready var sfx: AudioStreamPlayer2D = $Voice
@onready var select: AudioStreamPlayer2D = $Menu

const CHAR_READ_RATE=0.1
var text_tween
var current_state = State.READY
var text_queue = []

enum State{
	READY,
	READING,
	FINISHED
}

func _ready() -> void:
	change_state(State.READY)
	# FIX: For now a single line of text cant be longer than 52 characters or it'll get cut off
	queue_text("Lmao your mama gay hahahha")
	queue_text("Your dad lowkey fruity too")

func _process(delta: float) -> void:
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				text_tween.stop()
				spoken_text.visible_ratio=1
				change_state(State.FINISHED)
				select.play()
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				select.play()
				if len(text_queue) == 0:
					hide_textbox()
				

func queue_text(text):
	text_queue.push_back(text)

func display_text():
	var next_text = text_queue.pop_front()
	play_sfx(len(next_text))
	show_textbox()
	spoken_text.text=next_text
	change_state(State.READING)
	text_tween = create_tween()
	spoken_text.visible_ratio=0
	text_tween.tween_property(spoken_text,"visible_ratio",1,len(next_text)*CHAR_READ_RATE)
	await text_tween.finished
	change_state(State.FINISHED)

func hide_textbox():
	text_box_container.hide()
	character_name.text=""
	spoken_text.text=""
	
func show_textbox():
	text_box_container.show()

func change_state(state):
	current_state=state

func play_sfx(length):
	for x in range(length):
		if current_state == State.READING:
			sfx.play()
		elif current_state == State.FINISHED:
			break
		await get_tree().create_timer(CHAR_READ_RATE).timeout
