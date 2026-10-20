extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 0.185
const tile_size: Vector2 = Vector2(32,32)
var sprite_node_pos_tween: Tween

func _ready() -> void:
	sprite.play("default")

func _physics_process(_delta):
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_pressed("up") and !$up.is_colliding():
			_move(Vector2(0,-1))
			sprite.play("walk up")
		elif Input.is_action_pressed("down") and !$down.is_colliding():
			_move(Vector2(0,1))
			sprite.play("walk down")			
		elif Input.is_action_pressed("left") and !$left.is_colliding():
			_move(Vector2(-1,0))
			sprite.play("walk side")
			sprite.flip_h = true	
		elif Input.is_action_pressed("right") and !$right.is_colliding():
			_move(Vector2(1,0))
			sprite.play("walk side")
			sprite.flip_h = false

func _move(dir: Vector2):
	global_position += dir * tile_size
	sprite.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite, "global_position", global_position,speed).set_trans(Tween.TRANS_LINEAR)
