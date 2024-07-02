extends Node

## The dictionary holds recipes keyed to their types.
const CRAFTING: Dictionary = {

}

## A dictionary of data for smelting machines. Keyed to the type, with an
## inputs dictionary of input type with amounts and an amount of time it takes
## to craft.
const SMELTING: Dictionary = {
	Library.TYPE.INGOT: {inputs = {Library.TYPE.ORE: 1}, amount = 1, time = 5.0}
}
