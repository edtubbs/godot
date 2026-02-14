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
- `docs/dependencies.md`
