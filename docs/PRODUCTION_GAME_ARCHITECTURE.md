# XrGpt Production Game Architecture Contract

Status: ACTIVE IMPLEMENTATION CONTRACT
Target engine: Godot 4.6.1
Primary XR target: Meta Quest 3S
Flat target: desktop fallback
Repository: 0SwiftKnightX/XrGpt

## Purpose

This document translates the supplied "Godot 4 Production-Ready Cross-Play Game Architecture" brief into the existing XrGpt foundation without discarding or replacing verified systems.

The existing XrGpt README remains the authoritative historical record. This document is an implementation contract, not a replacement for that history.

## Non-negotiable compatibility rules

1. Godot 4.6.1 is authoritative for this repository.
2. Existing XR Tools addon files are vendored dependencies and must not be modified for gameplay implementation.
3. Existing inventory, equipment, attachment, world-environment, XR interaction, and validation contracts remain authoritative unless a concrete defect is demonstrated.
4. Runtime and physical Quest 3S behavior must not be claimed from static inspection or CI alone.
5. Every implementation phase must have an executable validation path before being marked complete.
6. No large speculative refactor is allowed when a targeted integration can satisfy the requirement.
7. The user's supplied sample code is a design reference, not copy/paste production code. Any Godot 4.6.1 API mismatch must be corrected before implementation.

## Current foundation mapped to the brief

### Already present

- XR Tools integration and controller interaction.
- Canonical XR control vocabulary under `gameplay/input/control_scheme.gd`.
- Player rig foundation under `gameplay/player/player_rig.gd`.
- Inventory service/container/read-model architecture.
- Item definitions, instances, capabilities, procedural physical-item bridge.
- Equipment and attachment systems, including Phase 1 regression validation.
- World environment root, biome/region definitions, day/night cycle, lighting exposure.
- HUD board/manager/settings foundation.
- GitHub Actions Godot 4.6.1 validation.
- Meta Quest 3S Android export preset.
- Manual Quest 3S debug APK workflow.
- Append-only README continuity log.

### Not yet verified as production gameplay

- A complete locomotion controller with room-scale offset handling plus collision/gravity.
- Flat-mode player controller and cross-mode input abstraction.
- Production avatar presentation/animation.
- Modular vehicle assembly and wheel/suspension physics.
- Garage terminal and build-area interaction loop.
- Anime HUD/minimap/fast-travel presentation.
- Cel-shaded production visual pipeline.
- Tower-defense combat loop.
- Character customization and skill-tree runtime.
- Persistent save/load for the complete gameplay state.
- Multiplayer/network synchronization and true cross-play session behavior.
- Quest 3S physical runtime/export verification.

## Implementation order

### Gate 1 — Player locomotion foundation

Deliver:
- CharacterBody3D gameplay body.
- XR origin/tracking offset architecture compatible with room-scale movement.
- Gravity and floor detection.
- Smooth movement and snap/smooth turning.
- Flat mouse/keyboard fallback through shared gameplay actions.
- Mount/dismount interface that does not corrupt XR origin transforms.
- Avatar visibility policy for local VR versus remote/flat presentation.

Validation:
- Static contract audit.
- Godot 4.6.1 CI import/parse.
- Automated player-system audit where practical.
- Physical Quest 3S test before runtime completion is claimed.

### Gate 2 — Equipment/interaction integration

Deliver:
- Existing inventory/equipment contracts remain the source of truth.
- Equipment attachment sockets remain authoritative.
- Pickable world parts use existing XR Tools lifecycle.
- Interaction filters and collision layers are explicit.
- No duplicate item definitions or instances.

Validation:
- Existing attachment regression suite.
- Inventory architecture audit.
- XR connection audit.

### Gate 3 — Vehicle engineering

Deliver:
- Vehicle assembly root with a deterministic part graph.
- 1 m grid socket model.
- 1x1x1 and 2x1x1 structural parts.
- Wheels with contact/suspension logic.
- Seat and steering interfaces.
- Engine/throttle/brake abstraction.
- Mass/inertia recalculation.
- Blueprint serialization using the existing blueprint/versioning architecture when present.
- Deterministic assemble/disassemble behavior.

Important correction:
The vehicle system must not simply reparent arbitrary independent RigidBody3D parts under another RigidBody3D and expect physics to propagate correctly. Production assembly needs a defined physical ownership model: either one authoritative rigid body with part collision shapes attached to it, or a deliberately constrained multi-body assembly. The implementation must choose one model and validate it.

### Gate 4 — Garage and gameplay loop

Deliver:
- Garage/build pad.
- Part browser/terminal.
- Build/edit/save/load/summon flow.
- Exit garage into normal play.
- Vehicle ownership and persistence hooks.

### Gate 5 — HUD/navigation

Deliver:
- Hero Module-compatible spatial UI integration.
- Health/energy/status presentation.
- Minimap with bounded rendering cost.
- Waypoint registry.
- Fast travel with safe player relocation.
- Respawn/fail-state handling.

Fast travel must be a gameplay service, not a HUD-owned teleport implementation.

### Gate 6 — Visual pipeline

Deliver:
- Quest-compatible anime/cel shading.
- Outlines implemented with a measured XR performance budget.
- WorldEnvironment tuned for standalone XR.
- Flash-step feedback using bounded particles/post effects.

The supplied brief's desktop-quality volumetric/post-processing settings cannot be enabled blindly on Quest 3S. Visual features must be gated by renderer/device capability.

### Gate 7 — Tower defense

Deliver:
- Crystal objective.
- Enemy health/damage contract.
- Deterministic path-following wave system.
- Turret target acquisition.
- Projectile/damage interface.
- Wave lifecycle.
- Defeat/completion state.

Target selection must use path progress or explicit target priority, not raw world Z coordinates.

### Gate 8 — Character and skills

Deliver:
- Data-driven avatar customization.
- Appearance configuration.
- Skill graph and prerequisite validation.
- Persistent state integration.

### Gate 9 — Persistence

Deliver:
- Versioned save schema.
- Inventory/equipment state.
- Blueprint state.
- Character state.
- Skills.
- Waypoints.
- World progression.

Existing blueprint versioning rules must be preserved and migrated explicitly.

### Gate 10 — Cross-play/network layer

Deliver:
- Shared gameplay simulation contracts for XR and Flat.
- Authority/ownership model.
- Network-safe player, vehicle, inventory, combat, and progression state.
- Session lifecycle.
- Reconciliation/replication tests.

"Runs in VR and Flat" is not by itself multiplayer cross-play. True cross-play requires a networking layer and synchronized authoritative state.

## One-hour execution constraint

The supplied one-hour checklist is treated as an automation-window target, not a promise that a complete production game can be safely authored and verified in one hour.

Within one automated window, agents may implement a bounded vertical slice and validation gates. They must not mark systems complete merely because files/scenes were created.

## Completion vocabulary

- DESIGNED — contract exists.
- IMPLEMENTED — code/assets exist.
- STATIC VERIFIED — structure/API checks pass.
- CI VERIFIED — repository validation passes.
- RUNTIME VERIFIED — executable Godot test passes.
- QUEST VERIFIED — physical Meta Quest 3S test passes.
- PRODUCTION READY — all required gates for the defined release scope are verified.

A system is not PRODUCTION READY when it is only IMPLEMENTED.

## First implementation target

The next coding gate is **Player Locomotion Foundation**, because movement, gravity, collision, XR room-scale handling, Flat fallback, and mount state are prerequisites for meaningful testing of the garage, vehicle, tower-defense, HUD, and world interaction loops.
