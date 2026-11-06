extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_offset = sprite.position
@export var speed = 0.185
@export var min_wait = 1.0
@export var max_wait = 3.0
const tile_size: Vector2 = Vector2(32,32)
var sprite_node_pos_tween: Tween
var idle_anim = "default"
var wait_time = 0.0

func _ready() -> void:
	sprite.play("default")
	wait_time = randf_range(min_wait, max_wait)

func _physics_process(delta):
	if sprite_node_pos_tween and sprite_node_pos_tween.is_running():
		return

	sprite.play(idle_anim)
	wait_time -= delta
	if wait_time > 0:
		return
	wait_time = randf_range(min_wait, max_wait)

	match randi() % 4:
		0:
			if !$up.is_colliding():
				_move(Vector2(0,-1))
				sprite.play("walk up")
			idle_anim = "idle up"
		1:
			if !$down.is_colliding():
				_move(Vector2(0,1))
				sprite.play("walk down")
			idle_anim = "default"
		2:
			if !$left.is_colliding():
				_move(Vector2(-1,0))
				sprite.play("walk side")
			sprite.flip_h = true
			idle_anim = "idle side"
		3:
			if !$right.is_colliding():
				_move(Vector2(1,0))
				sprite.play("walk side")
			sprite.flip_h = false
			idle_anim = "idle side"

func _move(dir: Vector2):
	global_position += dir * tile_size
	sprite.position -= dir * tile_size

	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite, "position", sprite_offset, speed).set_trans(Tween.TRANS_LINEAR)
