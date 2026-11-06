extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 0.185
const tile_size: Vector2 = Vector2(32,32)
var sprite_node_pos_tween: Tween
var idle_anim = "default"
@onready var sprite_offset = sprite.position

func _ready() -> void:
	sprite.play("default")

func _physics_process(_delta):
	if sprite_node_pos_tween and sprite_node_pos_tween.is_running():
		return

	if Input.is_action_pressed("up"):
		idle_anim = "idle up"
		if _can_move($up):
			_move(Vector2(0,-1))
			sprite.play("walk up")
			return
	elif Input.is_action_pressed("down"):
		idle_anim = "default"
		if _can_move($down):
			_move(Vector2(0,1))
			sprite.play("walk down")
			return
	elif Input.is_action_pressed("left"):
		idle_anim = "idle side"
		sprite.flip_h = true
		if _can_move($left):
			_move(Vector2(-1,0))
			sprite.play("walk side")
			return
	elif Input.is_action_pressed("right"):
		idle_anim = "idle side"
		sprite.flip_h = false
		if _can_move($right):
			_move(Vector2(1,0))
			sprite.play("walk side")
			return

	sprite.play(idle_anim)

# Re-check the ray right now, so we see an NPC that just stepped into that tile
func _can_move(ray: RayCast2D):
	ray.force_raycast_update()
	return !ray.is_colliding()

func _move(dir: Vector2):
	global_position += dir * tile_size
	sprite.position -= dir * tile_size

	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite, "position", sprite_offset, speed).set_trans(Tween.TRANS_LINEAR)
