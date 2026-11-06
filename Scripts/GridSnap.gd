extends Node2D
# Snaps every Node2D child to the centre of a grid tile when the scene starts.
# UI (Control nodes) and tilemaps are left alone.
const tile_size: Vector2 = Vector2(32,32)

func _ready() -> void:
	for child in get_children():
		if child is Node2D and not (child is TileMap or child is TileMapLayer):
			child.global_position = (child.global_position / tile_size).floor() * tile_size + tile_size / 2
