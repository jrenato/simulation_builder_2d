# Entities and Blueprints

The game uses a modular entity system where every object in the world is an `Entity`.

## Base Classes

### `Entity`
The base class for all placeable objects in the game. It handles common properties like position, type, and system registration.
- **Properties**:
  - `type`: The `Library.TYPE` of the entity.
  - `is_transmitting`: Whether the entity can transmit power/items.

### `BlueprintEntity`
A specialized entity used for placement preview. It handles valid/invalid placement logic and visual feedback.

## Common Entities

- **Stirling Engine**: A base power generator that consumes fuel.
- **Battery**: Stores surplus power and provides it when sources are insufficient.
- **Wire**: Low-level transmitter for power.
- **Chest**: Provides storage for items.
- **Furnace / Electric Furnace**: Processes recipes (e.g., Ore -> Ingot).

## Interaction Flow

1. **Selection**: Player selects an item from the GUI.
2. **Preview**: A `BlueprintEntity` is created and follows the mouse cursor.
3. **Placement**: If valid, `EntityPlacer` creates the real `Entity` and places it on the map.
4. **Registration**: The new entity registers itself with relevant systems (Power, Work) via signals.
5. **Update**: Systems include the entity in their tick processing.
