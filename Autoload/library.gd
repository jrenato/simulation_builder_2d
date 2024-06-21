extends Node

enum TYPE {
	STIRLING,
	BATTERY,
	WIRE,
	BRANCH,
	INGOT,
	AXE,
	CRUDE_AXE,
	PICKAXE,
	CRUDE_PICKAXE,
}

## This dictionary holds the names of the entities keyed to their types.
var entity_names: Dictionary = {
	TYPE.STIRLING: "Stirling Engine",
	TYPE.BATTERY: "Battery",
	TYPE.WIRE: "Wire",
	TYPE.BRANCH: "Branch",
	TYPE.INGOT: "Ingot",
	TYPE.AXE: "Axe",
	TYPE.CRUDE_AXE: "Crude Axe",
	TYPE.PICKAXE: "Pickaxe",
	TYPE.CRUDE_PICKAXE: "Crude Pickaxe",
}

## This dictionary holds the entities keyed to their types.
var entities: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_entity.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_entity.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_entity.tscn"),
	TYPE.BRANCH: load("res://Entities/Common/Branch/branch_entity.tscn"),
}

## The dictionary holds blueprints keyed to their types.
var blueprints: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_blueprint.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_blueprint.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_blueprint.tscn"),
	TYPE.BRANCH: load("res://Entities/Common/Branch/branch_blueprint.tscn"),
	TYPE.INGOT: load("res://Entities/Common/Ingot/ingot_blueprint.tscn"),
	TYPE.AXE: load("res://Entities/Tools/axe_blueprint.tscn"),
	TYPE.CRUDE_AXE: load("res://Entities/Tools/crude_axe_blueprint.tscn"),
	TYPE.PICKAXE: load("res://Entities/Tools/pickaxe_blueprint.tscn"),
	TYPE.CRUDE_PICKAXE: load("res://Entities/Tools/crude_pickaxe_blueprint.tscn"),
}

## The dictionary holds recipes keyed to their types.
var recipes: Dictionary = {
	TYPE.STIRLING: load("res://Systems/Recipes/stirling_engine_recipe.tres"),
	TYPE.BATTERY: load("res://Systems/Recipes/battery_recipe.tres"),
	TYPE.WIRE: load("res://Systems/Recipes/wire_recipe.tres"),
}
