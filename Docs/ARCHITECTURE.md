# Project Architecture

This document describes the core architecture of Simulation Builder 2D.

## Core Systems

### Event Bus (`Events.gd`)
The `Events.gd` autoload (singleton) serves as a global event bus. It allows decoupled communication between various parts of the game.
- **Key Signals**:
  - `entity_placed(entity, cellv)`: Emitted when an entity is added to the map.
  - `entity_removed(entity, cellv)`: Emitted when an entity is removed.
  - `systems_ticked(delta)`: A global tick signal used by systems to synchronize updates.

### Entity Library (`Library.gd`)
The `Library.gd` autoload manages the registration and lookup of entities, blueprints, and recipes.
- **Data Structures**:
  - `TYPE`: An enum defining all available entity types.
  - `entities`: Maps `TYPE` to the actual entity `.tscn` file.
  - `blueprints`: Maps `TYPE` to the blueprint (ghost/preview) `.tscn` file.
  - `recipes`: Maps `TYPE` to the technical recipe (resources required).

### Power System
The Power System handles electrical grids. It uses a graph-based approach to connect sources (generators), receivers (consumers), and transmitters (wires).
- **Core Components**:
  - `PowerSystem`: Tracks all power-related entities and updates them on each tick.
  - `PowerSource`: Generates power.
  - `PowerReceiver`: Consumes power.
  - `PowerDirection`: Manages the flow of power through an entity.

### Work System
The Work System manages entities that perform processing tasks, like smelting or crafting.
- **Core Components**:
  - `WorkSystem`: Tracks all work-related entities and processes their progress.
  - `WorkComponent`: A component added to entities to handle their specific work logic (e.g., input requirements, processing time).

## Simulation Loop

The main simulation loop is controlled by `simulation.gd`. It uses a `Timer` to trigger `Events.systems_ticked` at a fixed rate (default 30 TPS).
1. `SystemsTimer` timeouts.
2. `Events.systems_ticked` is emitted.
3. Registered systems (Power, Work) receive the signal and update their state.
4. Entities update their internal state and visual representation based on system results.
