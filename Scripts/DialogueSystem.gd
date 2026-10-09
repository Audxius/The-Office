extends Control
@onready var label: Label = $ColorRect/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Hello"
	await text("Hello. My name is blah blah blah")
	text("Welcome to the world of of the office")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func text(string):
	label.text=""
	for letter in string.length():
		label.text+=string[letter]
		await get_tree().create_timer(0.05).timeout
