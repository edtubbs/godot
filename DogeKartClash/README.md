# DogeKart Clash (Bootstrap)

This repository now includes a bootstrap path that wires required upstream projects into a runnable integration workspace.

## One-click setup

From the repository root:

```bash
./setup_dogekart_clash.sh
```

To choose a custom output directory:

```bash
./setup_dogekart_clash.sh /absolute/path/to/DogeKartClash
```

Bring up local backend services and link addons:

```bash
./DogeKartClash/scripts/dev_up.sh
```

Regenerate all included models with Blender:

```bash
./DogeKartClash/scripts/generate_models.sh
```

## Required upstream repositories

The setup script clones the exact dependencies required by the prompt into `third_party/`:

- https://github.com/godotengine/godot
- https://github.com/32kda/vehicle_sample
- https://github.com/kirca/godot_vehicle_arcade
- https://github.com/NoisyChain/Sakuga-Engine
- https://github.com/heroiclabs/nakama
- https://github.com/heroiclabs/nakama-godot
- https://github.com/maximkulkin/godot-rollback-netcode
- https://github.com/dogecoinfoundation/libdogecoin
- https://github.com/dogecoinfoundation/gigawallet
- https://github.com/dogecoin/dogecoin
- https://github.com/PsyProtocol/doge-sdk
- https://github.com/Dogebox-WG/os
- https://github.com/dogeorg/dogeboxd
- https://github.com/Dogebox-WG/dogenet
- https://github.com/dogeorg/dpanel
- https://github.com/Saitodepaula/Godot-6DOF-Vehicle-Demo
- https://github.com/DAShoe1/Godot-Easy-Vehicle-Physics

## Scaffold layout

The script creates this structure:

```
DogeKartClash/
├── godot/
├── pup/
├── docs/
├── assets/
├── scripts/
├── third_party/
└── docker-compose.yml
```

It also generates:

- `godot/project.godot` bootstrap project file
- `pup/manifest.json` and `pup/pup.nix`
- `scripts/link_addons.sh` and `scripts/dev_up.sh`
- `scripts/generate_models.sh` + `scripts/generate_models_blender.py` (Blender model generation)
- `docs/dependencies.md`
- `assets/models/` with included placeholder 3D models:
  - 5 kart models (`shiba_kart_01..05.obj`)
  - 3 track models (`moon_loop_track.obj`, `doge_city_track.obj`, `shiba_temple_track.obj`)
  - 1 fighter model (`shiba_fighter.obj`)
