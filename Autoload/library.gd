extends Node

enum TYPE {
	STIRLING,
	BATTERY,
	WIRE,
	BRANCH,
	INGOT,
}

## This dictionary holds the names of the entities keyed to their types.
var entity_names: Dictionary = {
	TYPE.STIRLING: "Stirling Engine",
	TYPE.BATTERY: "Battery",
	TYPE.WIRE: "Wire",
	TYPE.BRANCH: "Branch",
	TYPE.INGOT: "Ingot",
}

## This dictionary holds the entities keyed to their types.
var entities: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_entity.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_entity.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_entity.tscn"),
	TYPE.BRANCH: load("res://Entities/Common/Branch/branch_entity.tscn"),
	TYPE.INGOT: "Ingot",
}

## The dictionary holds blueprints keyed to their types.
var blueprints: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_blueprint.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_blueprint.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_blueprint.tscn"),
	TYPE.BRANCH: load("res://Entities/Common/Branch/branch_blueprint.tscn"),
	TYPE.INGOT: load("res://Entities/Common/Ingot/ingot_blueprint.tscn"),
}

## The dictionary holds recipes keyed to their types.
var recipes: Dictionary = {
	TYPE.STIRLING: "res://Systems/Recipes/stirling_engine_recipe.tres",
	TYPE.BATTERY: "res://Systems/Recipes/battery_recipe.tres",
	TYPE.WIRE: "res://Systems/Recipes/wire_recipe.tres",
}
