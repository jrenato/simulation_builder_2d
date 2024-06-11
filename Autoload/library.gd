extends Node

enum TYPE {
	STIRLING,
	BATTERY,
	WIRE,
}

## This dictionary holds the entities keyed to their types.
var entities: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_entity.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_entity.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_entity.tscn"),
}

## The dictionary holds blueprints keyed to their types.
var blueprints: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_blueprint.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_blueprint.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_blueprint.tscn"),
}
