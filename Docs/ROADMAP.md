# Development Roadmap

This document outlines potential future improvements and features for Simulation Builder 2D, providing technical context and implementation checklists for each goal.

## Architecture & Core Systems

### Enhanced Componentization
Standardize machine logic into reusable components.
- [ ] **InventoryComponent**:
    - [ ] Create `inventory_component.gd` base class.
    - [ ] Implement `can_accept_item(type)`, `add_item(type, amount)`, and `remove_item(type, amount)`.
    - [ ] Add `inventory_changed` and `item_overflow` signals.
    - [ ] Integrate with `Library.is_valid_filter` for automatic slot filtering.
- [ ] **Health & Durability**:
    - [ ] Create `impact_component.gd` for structural integrity.
    - [ ] Implement `MaintenanceSystem` to manage global machine wear.
    - [ ] Add visual feedback (e.g., smoke or sparks) for low-durability entities.

### Spatial Partitioning (Chunking)
Optimize performance for large-scale automation.
- [ ] **Grid Management**:
    - [ ] Define chunk size (e.g., 16x16 tiles).
    - [ ] Create `MapManager` to track entity counts per chunk.
- [ ] **Logic**:
    - [ ] Implement `update_chunk_state()` to flag chunks as "Active" or "Hibernating".
    - [ ] Update `PowerSystem` and `WorkSystem` to skip entities in "Hibernating" chunks.
    - [ ] Add logic to always activate chunks near the `Player`.

### Robust Save/Load System
Enable persistent worlds and sessions.
- [ ] **Serialization**:
    - [ ] Create `to_dict()` and `from_dict(data)` in `Entity.gd`.
    - [ ] Implement global `SaveManager` to collect data from all entities in `EntityTracker`.
- [ ] **Reconstruction**:
    - [ ] Logic to clear and rebuild the map from a save file using `Library.entities`.
    - [ ] Properly restore system connections (Power Grids) after entities are instantiated.

## Gameplay & Features

### Logistical Automation
Build true factory-style automation.
- [ ] **Inserters**:
    - [ ] Implement swing/movement logic between source and target cells.
    - [ ] Add logic to pull items from `Chest`/`Furnace` inventories using `InventoryComponent`.
- [ ] **Conveyor Belts**:
    - [ ] Create `conveyor_entity.gd` with directional logic.
    - [ ] Optimize item movement using a shared `BeltManager` to minimize per-item node overhead.
    - [ ] Implement "Belt Sideloading" and "Compression" logic.

### Power Grid Visualisation
Improve feedback for electrical networks.
- [ ] **Power Overlay**:
    - [ ] Implement a toggleable `CanvasLayer` for grid visualization.
    - [ ] Create a shader for `Wire` entities to show energy pulses.
- [ ] **Status Indicators**:
    - [ ] Create a standard `StatusIcon` node (e.g., "⚡" for no power).
    - [ ] Implement logic in `Entity` to display these icons when system requirements aren't met.

## User Interface & Feedback

### System Monitoring Dashboards
Provide deep insights into factory performance.
- [ ] **Power Analytics**:
    - [ ] Create a real-time line graph UI using `Line2D` or a custom texture.
    - [ ] Implement "Grid Analysis" logic to sum up production vs. consumption.
- [ ] **Efficiency Heatmap**:
    - [ ] Create a world-space overlay with color-coding (e.g., Green = Operating, Red = Bottlenecked).
    - [ ] Track machine "Uptime Percentage" in `WorkComponent`.
