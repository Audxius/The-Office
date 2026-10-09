extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 200

func _ready() -> void:
	sprite.play("default")

func _physics_process(_delta):
	velocity = Vector2(0,0)

	if Input.is_action_pressed("up"):
		velocity.y = -speed
		sprite.play("walk up")
	elif Input.is_action_just_released("up"):
		sprite.play("idle up")
		
	if Input.is_action_pressed("down"):
		velocity.y = speed
		sprite.play("walk down")
	elif Input.is_action_just_released("down"):
		sprite.play("default")
		
	if Input.is_action_pressed("left"):
		velocity.x = -speed
		sprite.flip_h = true
		sprite.play("walk side")
	elif Input.is_action_just_released("left"):
		sprite.play("idle side")
		
	if Input.is_action_pressed("right"):
		velocity.x = speed
		sprite.flip_h = false
		sprite.play("walk side")
	elif Input.is_action_just_released("right"):
		sprite.play("idle side")

	move_and_slide()
