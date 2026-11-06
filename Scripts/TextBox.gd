extends CanvasLayer

@onready var spoken_text: Label = $TextBoxContainer/TextureRect/MarginContainer/VBoxContainer/SpokenText
@onready var character_name: Label = $TextBoxContainer/TextureRect/MarginContainer/VBoxContainer/CharacterName
@onready var sfx: AudioStreamPlayer2D = $Voice
@onready var select: AudioStreamPlayer2D = $Menu
@onready var next_indicator: Label = $TextBoxContainer/TextureRect/NextIndicator

const CHAR_READ_RATE=0.04
var text_tween
var current_state = State.READY
var text_queue = []
var indicator_y = 0.0

enum State{
	READY,
	READING,
	FINISHED
}

func _ready() -> void:
	# Lay out the whole page before typing, so words don't jump to the next line mid-typing
	spoken_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	change_state(State.READY)
	hide_textbox()

func talk(speaker, lines):
	character_name.text = speaker
	for line in lines:
		queue_text(line)

func is_open():
	return visible

func _process(_delta: float) -> void:
	if current_state == State.READY and !text_queue.is_empty():
		display_text()
	# Bounce the "more text" arrow
	next_indicator.position.y = indicator_y + sin(Time.get_ticks_msec() * 0.01) * 2

func _unhandled_input(event: InputEvent) -> void:
	if !event.is_action_pressed("action"):
		return
	match current_state:
		State.READING:
			get_viewport().set_input_as_handled()
			text_tween.stop()
			spoken_text.visible_ratio=1
			change_state(State.FINISHED)
			select.play()
		State.FINISHED:
			get_viewport().set_input_as_handled()
			change_state(State.READY)
			select.play()
			if len(text_queue) == 0:
				hide_textbox()
				

func queue_text(text):
	text = text.replace("\\n", "\n") # a typed \n becomes a real new line
	while text.contains("\n "): # drop spaces at the start of a new line
		text = text.replace("\n ", "\n")
	text_queue.push_back(text)

# Returns as many words as fit in the textbox, the rest goes back in the queue as the next page
func fit_page(text):
	var words = text.replace("\n", " \n").split(" ") # "a\nb" -> "a", "\nb", so new lines stick to the next word
	var page = words[0]
	for i in range(1, len(words)):
		spoken_text.text = (page + " " + words[i]).replace(" \n", "\n")
		if spoken_text.get_line_count() > spoken_text.get_visible_line_count():
			text_queue.push_front(" ".join(words.slice(i)).replace(" \n", "\n").lstrip("\n"))
			break
		page = spoken_text.text
	return page

func display_text():
	change_state(State.READING)
	show_textbox()
	await get_tree().process_frame # let the textbox get its size before measuring
	var next_text = fit_page(text_queue.pop_front())
	play_sfx(len(next_text))
	spoken_text.text=next_text
	place_indicator()
	text_tween = create_tween()
	spoken_text.visible_ratio=0
	text_tween.tween_property(spoken_text,"visible_ratio",1,len(next_text)*CHAR_READ_RATE)
	await text_tween.finished
	change_state(State.FINISHED)

# Puts the "more text" arrow right after the last word on the page
func place_indicator():
	var last_char = spoken_text.get_character_bounds(len(spoken_text.text) - 1)
	next_indicator.global_position = spoken_text.global_position + Vector2(last_char.end.x + 8, last_char.get_center().y - next_indicator.size.y / 2)
	indicator_y = next_indicator.position.y

func hide_textbox():
	hide()
	character_name.text=""
	spoken_text.text=""
	
func show_textbox():
	show()

func change_state(state):
	current_state=state
	next_indicator.visible = state == State.FINISHED and !text_queue.is_empty()

func play_sfx(length):
	for x in range(length):
		if current_state == State.READING:
			sfx.play()
		elif current_state == State.FINISHED:
			break
		await get_tree().create_timer(CHAR_READ_RATE).timeout
