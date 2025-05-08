class_name MapTile
extends Node2D # Or StaticBody2D, or whatever base type your tile scenes use

## Set this in the inspector for each tile scene (walkable_tile.tscn, wall_tile.tscn, etc.)
@export var is_walkable: bool = true
