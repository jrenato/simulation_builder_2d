# Simulation Builder 2D

A 2D simulation game built with Godot 4, focusing on automation, resource management, and power systems.

## Overview

Simulation Builder 2D is a sandbox game where players can build and manage complex systems. The game features a modular entity system, a global event bus, and specialized systems for power distribution and work processing.

## Key Features

- **Entity System**: Modular and extensible system for various world objects (Stirling Engines, Batteries, Wires, etc.).
- **Power System**: Manages power generation, distribution, and consumption across the map.
- **Work System**: Handles task processing and recipe-based production (e.g., smelting in furnaces).
- **Global Event Bus**: Decoupled communication between systems and entities via the `Events` autoload.
- **GUI**: Interactive interface for entity management, inventory, and system monitoring.

## Project Structure

- `Autoload/`: Global singletons (`Events`, `Library`, `Recipes`).
- `Entities/`: All game world objects and their logic.
- `Systems/`: Core logic for simulation, power, and work.
- `GUI/`: User interface components and menus.
- `Assets/`: Visual and audio resources.

## Getting Started

1. Open the project in Godot 4.
2. Run `res://Systems/Simulation.tscn` to start the game.

## Documentation

For more detailed information, see:
- [ARCHITECTURE.md](Docs/ARCHITECTURE.md)
- [ENTITIES.md](Docs/ENTITIES.md)
- [ROADMAP.md](Docs/ROADMAP.md)
