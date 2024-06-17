extends Node

## Signal emitted when the player places an entity, passing the entity and its
## position in map coordinates
signal entity_placed(entity: Entity, cellv: Vector2i)

## Signal emitted when the player removes an entity, passing the entity and its
## position in map coordinates
signal entity_removed(entity: Entity, cellv: Vector2i)

## Signal emitted when the simulation triggers the systems for updates.
signal systems_ticked(delta: float)

## Signal emitted when the player has arrived at an item that can be picked up
signal entered_pickup_area(entity: Entity, player: Player)

## Emitted when the mouse hovers over any entity.
signal hovered_over_entity(entity: Entity)

## Emitted when an entity updates its tooltip.
signal info_updated(entity: Entity)
