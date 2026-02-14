#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-DogeKartClash}"
SKIP_CLONE="${SKIP_CLONE:-0}"

mkdir -p "${ROOT_DIR}"/{godot,pup,docs,assets,scripts,third_party}
mkdir -p "${ROOT_DIR}"/assets/models/{karts,tracks,fighters}

clone_if_missing() {
	local url="$1"
	local target="$2"
	if [ "${SKIP_CLONE}" = "1" ]; then
		return 0
	fi
	if [ ! -d "${target}/.git" ]; then
		git clone --depth 1 "${url}" "${target}"
	fi
}

clone_if_missing "https://github.com/godotengine/godot" "${ROOT_DIR}/third_party/godot"
clone_if_missing "https://github.com/32kda/vehicle_sample" "${ROOT_DIR}/third_party/vehicle_sample"
clone_if_missing "https://github.com/kirca/godot_vehicle_arcade" "${ROOT_DIR}/third_party/godot_vehicle_arcade"
clone_if_missing "https://github.com/NoisyChain/Sakuga-Engine" "${ROOT_DIR}/third_party/Sakuga-Engine"
clone_if_missing "https://github.com/heroiclabs/nakama" "${ROOT_DIR}/third_party/nakama"
clone_if_missing "https://github.com/heroiclabs/nakama-godot" "${ROOT_DIR}/third_party/nakama-godot"
clone_if_missing "https://github.com/maximkulkin/godot-rollback-netcode" "${ROOT_DIR}/third_party/godot-rollback-netcode"
clone_if_missing "https://github.com/dogecoinfoundation/libdogecoin" "${ROOT_DIR}/third_party/libdogecoin"
clone_if_missing "https://github.com/dogecoinfoundation/gigawallet" "${ROOT_DIR}/third_party/gigawallet"
clone_if_missing "https://github.com/dogecoin/dogecoin" "${ROOT_DIR}/third_party/dogecoin"
clone_if_missing "https://github.com/PsyProtocol/doge-sdk" "${ROOT_DIR}/third_party/doge-sdk"
clone_if_missing "https://github.com/Dogebox-WG/os" "${ROOT_DIR}/third_party/dogebox-os"
clone_if_missing "https://github.com/dogeorg/dogeboxd" "${ROOT_DIR}/third_party/dogeboxd"
clone_if_missing "https://github.com/Dogebox-WG/dogenet" "${ROOT_DIR}/third_party/dogenet"
clone_if_missing "https://github.com/dogeorg/dpanel" "${ROOT_DIR}/third_party/dpanel" || true
clone_if_missing "https://github.com/Saitodepaula/Godot-6DOF-Vehicle-Demo" "${ROOT_DIR}/third_party/Godot-6DOF-Vehicle-Demo"
clone_if_missing "https://github.com/DAShoe1/Godot-Easy-Vehicle-Physics" "${ROOT_DIR}/third_party/Godot-Easy-Vehicle-Physics"

cat > "${ROOT_DIR}/docs/README.md" <<'EOF'
# DogeKart Clash integration scaffold

This scaffold is generated from the root `setup_dogekart_clash.sh` script and provides:

- `godot/` for the playable project.
- `pup/` for Dogebox packaging (`pup.nix`, `manifest.json`).
- `assets/` for Blender exports.
- `scripts/` for deploy/test helpers.
- `third_party/` for required upstream dependencies.

The script clones all required upstream repositories listed in the issue prompt so integration can proceed in the required order.
EOF

cat > "${ROOT_DIR}/docs/dependencies.md" <<'EOF'
# Required upstream dependencies

| Category | Project | URL |
|----------|---------|-----|
| Engine | Godot 4.3+ | https://github.com/godotengine/godot |
| Racing Base | vehicle_sample | https://github.com/32kda/vehicle_sample |
| Arcade Karts | godot_vehicle_arcade | https://github.com/kirca/godot_vehicle_arcade |
| Fighting | Sakuga Engine | https://github.com/NoisyChain/Sakuga-Engine |
| Multiplayer | Nakama | https://github.com/heroiclabs/nakama |
| Multiplayer | nakama-godot | https://github.com/heroiclabs/nakama-godot |
| Netcode | godot-rollback-netcode | https://github.com/maximkulkin/godot-rollback-netcode |
| Crypto Core | libdogecoin | https://github.com/dogecoinfoundation/libdogecoin |
| Crypto API | GigaWallet | https://github.com/dogecoinfoundation/gigawallet |
| Dogecoin Node | Dogecoin Core | https://github.com/dogecoin/dogecoin |
| Web Crypto | doge-sdk | https://github.com/PsyProtocol/doge-sdk |
| Dogebox Platform | Dogebox OS | https://github.com/Dogebox-WG/os |
| Dogebox Platform | dogeboxd | https://github.com/dogeorg/dogeboxd |
| Dogebox Platform | dogenet | https://github.com/Dogebox-WG/dogenet |
| Dogebox Platform | dpanel | https://github.com/dogeorg/dpanel |
| Extras | Godot-6DOF-Vehicle-Demo | https://github.com/Saitodepaula/Godot-6DOF-Vehicle-Demo |
| Extras | Godot-Easy-Vehicle-Physics | https://github.com/DAShoe1/Godot-Easy-Vehicle-Physics |
EOF

cat > "${ROOT_DIR}/docker-compose.yml" <<'EOF'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: nakama
      POSTGRES_PASSWORD: localdb
    ports:
      - "5432:5432"

  nakama:
    image: heroiclabs/nakama:3.20.0
    depends_on:
      - postgres
    command:
      - "/nakama/nakama"
      - "migrate"
      - "up"
      - "--database.address"
      - "postgres:localdb@postgres:5432/nakama"
    ports:
      - "7349:7349"
      - "7350:7350"
      - "7351:7351"

  dogecoin:
    # NOTE: Replace with a Dogecoin Core container in production; this local RPC stub is for scaffold bootstrapping only.
    image: ruimarinho/bitcoin-core:24
    command:
      - "-regtest=1"
      - "-server=1"
      - "-rpcbind=0.0.0.0"
      - "-rpcallowip=0.0.0.0/0"
      - "-rpcuser=doge"
      - "-rpcpassword=doge"
    ports:
      - "18443:18443"
EOF

cat > "${ROOT_DIR}/scripts/link_addons.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "${ROOT_DIR}/godot/addons"

link_repo() {
	local source_dir="$1"
	local target_name="$2"
	if [ -d "${source_dir}" ]; then
		ln -sfn "${source_dir}" "${ROOT_DIR}/godot/addons/${target_name}"
	fi
}

link_repo "${ROOT_DIR}/third_party/nakama-godot/addons/com.heroiclabs.nakama" "com.heroiclabs.nakama"
link_repo "${ROOT_DIR}/third_party/godot-rollback-netcode/addons/rollback" "rollback"
link_repo "${ROOT_DIR}/third_party/godot_vehicle_arcade" "godot_vehicle_arcade"
link_repo "${ROOT_DIR}/third_party/Godot-Easy-Vehicle-Physics" "Godot-Easy-Vehicle-Physics"
EOF

cat > "${ROOT_DIR}/scripts/dev_up.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
docker compose -f "${ROOT_DIR}/docker-compose.yml" up -d
"${ROOT_DIR}/scripts/link_addons.sh"
echo "Backend services started and Godot addons linked."
EOF

cat > "${ROOT_DIR}/scripts/generate_models_blender.py" <<'EOF'
import bpy
import os

base = os.environ.get("DOGEKART_MODEL_DIR", os.path.join(os.getcwd(), "assets", "models"))
os.makedirs(os.path.join(base, "karts"), exist_ok=True)
os.makedirs(os.path.join(base, "tracks"), exist_ok=True)
os.makedirs(os.path.join(base, "fighters"), exist_ok=True)


def reset_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def export_cube(path, scale=(1.0, 1.0, 1.0)):
    reset_scene()
    bpy.ops.mesh.primitive_cube_add(size=2.0)
    obj = bpy.context.active_object
    obj.scale = scale
    bpy.ops.export_scene.obj(filepath=path, use_selection=False, axis_forward="-Z", axis_up="Y")
    gltf_path = path.rsplit(".", 1)[0] + ".gltf"
    bpy.ops.export_scene.gltf(filepath=gltf_path, export_format="GLTF_SEPARATE")


for i in range(1, 6):
    export_cube(os.path.join(base, "karts", f"shiba_kart_0{i}.obj"), (1.3, 0.6, 0.8))

export_cube(os.path.join(base, "tracks", "moon_loop_track.obj"), (6.0, 0.2, 6.0))
export_cube(os.path.join(base, "tracks", "doge_city_track.obj"), (7.0, 0.2, 5.0))
export_cube(os.path.join(base, "tracks", "shiba_temple_track.obj"), (5.5, 0.2, 7.0))
export_cube(os.path.join(base, "fighters", "shiba_fighter.obj"), (0.5, 1.1, 0.4))
EOF

cat > "${ROOT_DIR}/scripts/generate_models.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_DIR}"
blender --background --python "${ROOT_DIR}/scripts/generate_models_blender.py"
echo "Blender-generated models exported to ${ROOT_DIR}/assets/models (OBJ + glTF)"
EOF

cat > "${ROOT_DIR}/scripts/build_executable.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-}"
mkdir -p "${ROOT_DIR}/godot/build"

if [ -z "${GODOT_BIN}" ]; then
	if command -v godot4 >/dev/null 2>&1; then
		GODOT_BIN="godot4"
	elif command -v godot >/dev/null 2>&1; then
		GODOT_BIN="godot"
	fi
fi

if [ -n "${GODOT_BIN}" ]; then
	if "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-debug "Linux/X11" "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"; then
		chmod +x "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"
	else
		GODOT_BIN=""
	fi
fi

if [ -z "${GODOT_BIN}" ]; then
	cat > "${ROOT_DIR}/godot/build/DogeKartClash.x86_64" <<'LAUNCHER'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if command -v godot4 >/dev/null 2>&1; then
	exec godot4 --path "${PROJECT_DIR}"
elif command -v godot >/dev/null 2>&1; then
	exec godot --path "${PROJECT_DIR}"
else
	echo "Godot runtime not found. Install Godot 4 and run again."
	exit 1
fi
LAUNCHER
	chmod +x "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"
fi

tar -czf "${ROOT_DIR}/godot/build/DogeKartClash-linux.tar.gz" -C "${ROOT_DIR}/godot/build" DogeKartClash.x86_64
echo "Build complete: ${ROOT_DIR}/godot/build/DogeKartClash.x86_64"
echo "Artifact: ${ROOT_DIR}/godot/build/DogeKartClash-linux.tar.gz"
EOF

cat > "${ROOT_DIR}/scripts/build_pup.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "${ROOT_DIR}/pup/build"

if command -v nix >/dev/null 2>&1; then
	(
		cd "${ROOT_DIR}/pup"
		nix build -f pup.nix
	)
else
	tar -czf "${ROOT_DIR}/pup/build/dogekart-clash-pup.tar.gz" -C "${ROOT_DIR}/pup" manifest.json pup.nix
fi

if [ -d "${ROOT_DIR}/pup/result" ]; then
	tar -czf "${ROOT_DIR}/pup/build/dogekart-clash-pup.tar.gz" -C "${ROOT_DIR}/pup" result
fi

echo "PUP artifact: ${ROOT_DIR}/pup/build/dogekart-clash-pup.tar.gz"
EOF

cat > "${ROOT_DIR}/pup/manifest.json" <<'EOF'
{
  "name": "dogekart-clash",
  "version": "0.1.0",
  "description": "DogeKart Clash backend package for Dogebox",
  "services": [
    { "name": "nakama", "port": 7350 },
    { "name": "dogecoin-rpc", "port": 18443 }
  ]
}
EOF

cat > "${ROOT_DIR}/pup/pup.nix" <<'EOF'
{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "dogekart-clash-pup";
  src = ./.;
  installPhase = ''
    mkdir -p $out/share/dogekart-clash
    cp manifest.json $out/share/dogekart-clash/manifest.json
  '';
}
EOF

cat > "${ROOT_DIR}/godot/project.godot" <<'EOF'
; Engine configuration file.
; Minimal bootstrap project used for dependency integration.

config_version=5

[application]
config/name="DogeKartClash"
run/main_scene="res://scenes/Main.tscn"
EOF

mkdir -p "${ROOT_DIR}/godot"/{scenes,scripts}

cat > "${ROOT_DIR}/godot/scripts/main.gd" <<'EOF'
extends Node3D

@onready var kart: MeshInstance3D = $KartMesh

func _process(delta: float) -> void:
	kart.rotate_y(delta * 0.6)
EOF

cat > "${ROOT_DIR}/godot/scenes/Main.tscn" <<'EOF'
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/main.gd" id="1_main"]

[sub_resource type="BoxMesh" id="BoxMesh_1"]
size = Vector3(2, 0.8, 3)

[node name="Main" type="Node3D"]
script = ExtResource("1_main")

[node name="Camera3D" type="Camera3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.6, 8)

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866025, -0.5, 0, 0.12941, 0.224144, -0.965926, 0.482963, 0.836516, 0.258819, 0, 4, 0)

[node name="KartMesh" type="MeshInstance3D" parent="."]
mesh = SubResource("BoxMesh_1")
EOF

cat > "${ROOT_DIR}/godot/export_presets.cfg" <<'EOF'
[preset.0]
name="Linux/X11"
platform="Linux/X11"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/DogeKartClash.x86_64"
script_export_mode=1

[preset.0.options]
binary_format/embed_pck=true
EOF

write_model_obj() {
	local output_path="$1"
	cat > "${output_path}" <<'EOF'
o model
v -1.0 0.0 -1.0
v 1.0 0.0 -1.0
v 1.0 0.0 1.0
v -1.0 0.0 1.0
v -1.0 1.0 -1.0
v 1.0 1.0 -1.0
v 1.0 1.0 1.0
v -1.0 1.0 1.0
f 1 2 3 4
f 5 6 7 8
f 1 5 8 4
f 2 6 7 3
f 1 2 6 5
f 4 3 7 8
EOF
}

write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_01.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_02.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_03.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_04.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_05.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/moon_loop_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/doge_city_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/shiba_temple_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/shiba_fighter.obj"

chmod +x "${ROOT_DIR}/scripts/link_addons.sh" "${ROOT_DIR}/scripts/dev_up.sh" "${ROOT_DIR}/scripts/generate_models.sh" "${ROOT_DIR}/scripts/build_executable.sh" "${ROOT_DIR}/scripts/build_pup.sh"

echo "DogeKart Clash scaffold created at: ${ROOT_DIR}"
