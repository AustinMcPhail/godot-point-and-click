class_name Chunkloader
extends Node2D

var loaded_chunks = {}
#0, pos, 2, WATER_CELLS[randi_range(0, WATER_CELLS.size() - 1)]
func add_chunk(chunk_coords, chunk):
	loaded_chunks[chunk_coords] = chunk

func get_chunks():
	pass
