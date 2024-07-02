extends Node

enum TYPE {
	STIRLING,
	BATTERY,
	WIRE,

	BRANCH,
	TREE,
	LUMBER,
	BOULDER,
	STONE,
	ORE_BOULDER,
	ORE,
	INGOT,

	AXE,
	CRUDE_AXE,
	PICKAXE,
	CRUDE_PICKAXE,

	CHEST,
	COAL,
	CHARCOAL,

	FURNACE,
	NONE,
}

enum GROUP_TYPE {
	FUELS,
}

## This dictionary holds the names of the entities keyed to their types.
var entity_names: Dictionary = {
	TYPE.STIRLING: "Stirling Engine",
	TYPE.BATTERY: "Battery",
	TYPE.WIRE: "Wire",

	TYPE.BRANCH: "Branch",
	TYPE.TREE: "Tree",
	TYPE.LUMBER: "Lumber",
	TYPE.BOULDER: "Boulder",
	TYPE.STONE: "Stone",
	TYPE.ORE_BOULDER: "Ore Boulder",
	TYPE.ORE: "Ore",
	TYPE.INGOT: "Ingot",

	TYPE.AXE: "Axe",
	TYPE.CRUDE_AXE: "Crude Axe",
	TYPE.PICKAXE: "Pickaxe",
	TYPE.CRUDE_PICKAXE: "Crude Pickaxe",

	TYPE.CHEST: "Chest",

	TYPE.FURNACE: "Furnace",
}

## This dictionary holds the entities keyed to their types.
var entities: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_entity.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_entity.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_entity.tscn"),

	TYPE.BRANCH: load("res://Entities/Common/Branch/branch_entity.tscn"),
	TYPE.STONE: load("res://Entities/Common/Stone/stone_entity.tscn"),

	TYPE.CHEST: load("res://Entities/Chest/chest_entity.tscn"),
}

## The dictionary holds blueprints keyed to their types.
var blueprints: Dictionary = {
	TYPE.STIRLING: load("res://Entities/PowerSystem/StirlingEngine/stirling_engine_blueprint.tscn"),
	TYPE.BATTERY: load("res://Entities/PowerSystem/Battery/battery_blueprint.tscn"),
	TYPE.WIRE: load("res://Entities/PowerSystem/Wire/wire_blueprint.tscn"),

	TYPE.BRANCH: load("res://Entities/Common/Branch/branch_blueprint.tscn"),
	TYPE.LUMBER: load("res://Entities/Common/Lumber/lumber_blueprint.tscn"),
	TYPE.STONE: load("res://Entities/Common/Stone/stone_blueprint.tscn"),
	TYPE.ORE: load("res://Entities/Common/Ore/ore_blueprint.tscn"),
	TYPE.INGOT: load("res://Entities/Common/Ore/ingot_blueprint.tscn"),

	TYPE.AXE: load("res://Entities/Tools/axe_blueprint.tscn"),
	TYPE.CRUDE_AXE: load("res://Entities/Tools/crude_axe_blueprint.tscn"),
	TYPE.PICKAXE: load("res://Entities/Tools/pickaxe_blueprint.tscn"),
	TYPE.CRUDE_PICKAXE: load("res://Entities/Tools/crude_pickaxe_blueprint.tscn"),

	TYPE.CHEST: load("res://Entities/Chest/chest_blueprint.tscn"),

	TYPE.FURNACE: load("res://Entities/WorkSystem/Furnace/furnace_blueprint.tscn"),
}

var recipes: Dictionary = {
	TYPE.STIRLING: load("res://Systems/Recipes/stirling_engine_recipe.tres"),
	TYPE.BATTERY: load("res://Systems/Recipes/battery_recipe.tres"),
	TYPE.WIRE: load("res://Systems/Recipes/wire_recipe.tres"),
}


var entity_groups: Dictionary = {
	# Type -> efficiency
	GROUP_TYPE.FUELS: {
		TYPE.BRANCH: 10.0,
		TYPE.LUMBER: 50.0,
		TYPE.COAL: 60.0,
		TYPE.CHARCOAL: 60.0,
	}
}


## Returns `true` if the provided item matches the provided filter arrays.
func is_valid_filter(item_type: TYPE, item_filters: Array[Library.TYPE], group_filters: Array[Library.GROUP_TYPE]) -> bool:
	# It's an output only slot
	if TYPE.NONE in item_filters:
		return false

	# If there is no filter, any item is accepted
	if item_filters.is_empty() and group_filters.is_empty():
		return true

	# Item type is in item filters
	if item_type in item_filters:
		return true

	# If it's not, we check any listed item groups in the filter list and if
	# there's one defined, we look it up in the recipes.
	for group_filter in group_filters:
		if item_type in entity_groups[group_filter]:
			return true

	return false
