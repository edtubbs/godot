#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-DogeKartClash}"
SKIP_CLONE="${SKIP_CLONE:-0}"

mkdir -p "${ROOT_DIR}"/{godot,pup,docs,assets,scripts,third_party}
mkdir -p "${ROOT_DIR}"/assets/models/{karts,tracks,fighters}
mkdir -p "${ROOT_DIR}"/assets/blender/{karts,tracks,fighters}

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
import math
import os
import random

base = os.environ.get("DOGEKART_MODEL_DIR", os.path.join(os.getcwd(), "assets", "models"))
blend_base = os.environ.get("DOGEKART_BLEND_DIR", os.path.join(os.getcwd(), "assets", "blender"))
os.makedirs(os.path.join(base, "karts"), exist_ok=True)
os.makedirs(os.path.join(base, "tracks"), exist_ok=True)
os.makedirs(os.path.join(base, "fighters"), exist_ok=True)
os.makedirs(os.path.join(blend_base, "karts"), exist_ok=True)
os.makedirs(os.path.join(blend_base, "tracks"), exist_ok=True)
os.makedirs(os.path.join(blend_base, "fighters"), exist_ok=True)


def reset_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def export_scene(path):
    bpy.ops.export_scene.obj(filepath=path, use_selection=False, axis_forward="-Z", axis_up="Y")
    gltf_path = path.rsplit(".", 1)[0] + ".gltf"
    bpy.ops.export_scene.gltf(filepath=gltf_path, export_format="GLTF_SEPARATE")
    glb_path = path.rsplit(".", 1)[0] + ".glb"
    bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB")
    rel_path = os.path.relpath(path, base)
    blend_path = os.path.join(blend_base, os.path.splitext(rel_path)[0] + ".blend")
    os.makedirs(os.path.dirname(blend_path), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=blend_path, copy=True)


def make_kart(path):
    reset_scene()
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 0.5))
    body = bpy.context.active_object
    body.scale = (1.25, 0.8, 0.35)
    bpy.ops.object.shade_smooth()
    bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=24, radius=0.5, location=(0.25, 0, 1.0))
    canopy = bpy.context.active_object
    canopy.scale = (0.8, 0.55, 0.5)
    for wheel_x in (-0.95, 0.95):
        for wheel_y in (-0.75, 0.75):
            bpy.ops.mesh.primitive_torus_add(major_segments=36, minor_segments=16, major_radius=0.24, minor_radius=0.09, location=(wheel_x, wheel_y, 0.22))
            wheel = bpy.context.active_object
            wheel.rotation_euler[1] = math.pi / 2
            bpy.ops.object.shade_smooth()
    export_scene(path)


def make_track(path, scale=(6.0, 6.0), obstacles=12):
    reset_scene()
    bpy.ops.mesh.primitive_plane_add(size=2.0, location=(0, 0, 0))
    track = bpy.context.active_object
    track.scale = (scale[0], scale[1], 1.0)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.subdivide(number_cuts=18)
    bpy.ops.object.mode_set(mode="OBJECT")
    for v in track.data.vertices:
        v.co.z += 0.12 * random.uniform(-1.0, 1.0)
    for i in range(obstacles):
        angle = (i / obstacles) * (2 * math.pi)
        radius = min(scale) * 0.55
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.28, location=(radius * math.cos(angle), radius * math.sin(angle), 0.35))
    bpy.ops.object.shade_smooth()
    export_scene(path)


def make_fighter(path, height=1.9):
    reset_scene()
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.26, depth=height * 0.55, location=(0, 0, height * 0.52))
    torso = bpy.context.active_object
    bpy.ops.object.shade_smooth()
    bpy.ops.mesh.primitive_uv_sphere_add(segments=40, ring_count=20, radius=0.24, location=(0, 0, height * 0.95))
    bpy.ops.object.shade_smooth()
    for arm_x in (-0.33, 0.33):
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.08, depth=height * 0.34, location=(arm_x, 0, height * 0.66))
        arm = bpy.context.active_object
        arm.rotation_euler[1] = 0.22 * (-1 if arm_x < 0 else 1)
        bpy.ops.object.shade_smooth()
    for leg_x in (-0.12, 0.12):
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.09, depth=height * 0.42, location=(leg_x, 0, height * 0.24))
        bpy.ops.object.shade_smooth()
    export_scene(path)


for i in range(1, 13):
    make_kart(os.path.join(base, "karts", f"shiba_kart_{i:02d}.obj"))

make_track(os.path.join(base, "tracks", "moon_loop_track.obj"), (6.0, 6.0), obstacles=12)
make_track(os.path.join(base, "tracks", "doge_city_track.obj"), (7.0, 5.0), obstacles=14)
make_track(os.path.join(base, "tracks", "shiba_temple_track.obj"), (5.5, 7.0), obstacles=10)
make_track(os.path.join(base, "tracks", "wow_valley_track.obj"), (8.0, 4.5), obstacles=16)
make_track(os.path.join(base, "tracks", "to_the_moon_track.obj"), (4.8, 8.0), obstacles=18)
make_track(os.path.join(base, "tracks", "shibaverse_track.obj"), (8.2, 8.2), obstacles=20)
make_track(os.path.join(base, "tracks", "boneyard_ring_track.obj"), (6.8, 6.2), obstacles=14)
make_track(os.path.join(base, "tracks", "wow_speedway_track.obj"), (9.0, 5.0), obstacles=18)
make_fighter(os.path.join(base, "fighters", "shiba_fighter.obj"), height=1.8)
make_fighter(os.path.join(base, "fighters", "doge_knight_fighter.obj"), height=1.95)
make_fighter(os.path.join(base, "fighters", "moon_monk_fighter.obj"), height=1.88)
make_fighter(os.path.join(base, "fighters", "rocket_rider_fighter.obj"), height=1.92)
make_fighter(os.path.join(base, "fighters", "pixel_shiba_fighter.obj"), height=1.75)
make_fighter(os.path.join(base, "fighters", "dojo_guardian_fighter.obj"), height=2.0)
EOF

cat > "${ROOT_DIR}/scripts/generate_models.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_DIR}"
blender --background --python "${ROOT_DIR}/scripts/generate_models_blender.py"
echo "Blender-generated models exported to ${ROOT_DIR}/assets/models (OBJ + glTF + GLB)"
EOF

cat > "${ROOT_DIR}/scripts/build_executable.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-}"
GODOT_EXPORT_MODE="${GODOT_EXPORT_MODE:-release}"
mkdir -p "${ROOT_DIR}/godot/build"

if [ -z "${GODOT_BIN}" ]; then
	if command -v godot4 >/dev/null 2>&1; then
		GODOT_BIN="godot4"
	elif command -v godot >/dev/null 2>&1; then
		GODOT_BIN="godot"
	fi
fi

if [ -n "${GODOT_BIN}" ]; then
	if [ "${GODOT_EXPORT_MODE}" = "debug" ]; then
		if "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-debug "Linux/X11" "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"; then
			chmod +x "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"
		else
			GODOT_BIN=""
		fi
	else
		if "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-release "Linux/X11" "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"; then
			chmod +x "${ROOT_DIR}/godot/build/DogeKartClash.x86_64"
		else
			GODOT_BIN=""
		fi
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
mkdir -p "${ROOT_DIR}/pup/www"

if [ -f "${ROOT_DIR}/godot/build/web/index.html" ]; then
	cp -a "${ROOT_DIR}/godot/build/web/." "${ROOT_DIR}/pup/www/"
elif [ ! -f "${ROOT_DIR}/pup/www/index.html" ]; then
	cat > "${ROOT_DIR}/pup/www/index.html" <<'HTML'
<!doctype html>
<html><body><h1>DogeKart Clash PUP</h1><p>Build web bundle first to publish playable assets.</p></body></html>
HTML
fi

if command -v nix >/dev/null 2>&1; then
	(
		cd "${ROOT_DIR}/pup"
		nix build -f pup.nix
	)
fi

if [ -d "${ROOT_DIR}/pup/result" ]; then
	tar -czf "${ROOT_DIR}/pup/build/dogekart-clash-pup.tar.gz" -C "${ROOT_DIR}/pup" result
else
	tar -czf "${ROOT_DIR}/pup/build/dogekart-clash-pup.tar.gz" -C "${ROOT_DIR}/pup" manifest.json pup.nix www
fi

echo "PUP artifact: ${ROOT_DIR}/pup/build/dogekart-clash-pup.tar.gz"
EOF

cat > "${ROOT_DIR}/scripts/build_web_bundle.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-}"
DOGEKART_DOMAIN="${DOGEKART_DOMAIN:-dogekart-clash.example.com}"
GODOT_EXPORT_MODE="${GODOT_EXPORT_MODE:-release}"
REQUIRE_REAL_WEB_EXPORT="${REQUIRE_REAL_WEB_EXPORT:-0}"
mkdir -p "${ROOT_DIR}/godot/build/web"

if [ -z "${GODOT_BIN}" ]; then
	if command -v godot4 >/dev/null 2>&1; then
		GODOT_BIN="godot4"
	elif command -v godot >/dev/null 2>&1; then
		GODOT_BIN="godot"
	fi
fi

if [ -n "${GODOT_BIN}" ]; then
	if [ "${GODOT_EXPORT_MODE}" = "debug" ]; then
		if ! "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-debug "Web" "${ROOT_DIR}/godot/build/web/index.html"; then
			GODOT_BIN=""
		fi
	else
		if ! "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-release "Web" "${ROOT_DIR}/godot/build/web/index.html"; then
			GODOT_BIN=""
		fi
	fi
fi

if [ -z "${GODOT_BIN}" ]; then
	if [ "${REQUIRE_REAL_WEB_EXPORT}" = "1" ]; then
		echo "Real Godot Web export required, but no working Godot exporter was found." >&2
		exit 1
	fi
	cat > "${ROOT_DIR}/godot/build/web/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>DogeKart Clash - Web Build</title>
</head>
<body style="font-family:sans-serif;background:#111;color:#f5f5f5;">
  <h1>🐕 DogeKart Clash</h1>
  <p>Web export fallback bundle generated by CI scaffold.</p>
  <p>If a Godot Web export runtime is available in CI, this page is replaced with the full build.</p>
</body>
</html>
HTML
fi

printf "%s\n" "${DOGEKART_DOMAIN}" > "${ROOT_DIR}/godot/build/web/CNAME"
echo "Web bundle ready: ${ROOT_DIR}/godot/build/web"
echo "CNAME: ${DOGEKART_DOMAIN}"
EOF

cat > "${ROOT_DIR}/scripts/build_android_apk.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-}"
GODOT_EXPORT_MODE="${GODOT_EXPORT_MODE:-release}"
mkdir -p "${ROOT_DIR}/godot/build/android"

if [ -z "${GODOT_BIN}" ]; then
	if command -v godot4 >/dev/null 2>&1; then
		GODOT_BIN="godot4"
	elif command -v godot >/dev/null 2>&1; then
		GODOT_BIN="godot"
	fi
fi

if [ -n "${GODOT_BIN}" ]; then
	if [ "${GODOT_EXPORT_MODE}" = "debug" ]; then
		if ! "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-debug "Android" "${ROOT_DIR}/godot/build/android/DogeKartClash.apk"; then
			GODOT_BIN=""
		fi
	else
		if ! "${GODOT_BIN}" --headless --path "${ROOT_DIR}/godot" --export-release "Android" "${ROOT_DIR}/godot/build/android/DogeKartClash.apk"; then
			GODOT_BIN=""
		fi
	fi
fi

if [ -z "${GODOT_BIN}" ]; then
	tmpdir="$(mktemp -d)"
	printf "DogeKart Clash Android fallback artifact\n" > "${tmpdir}/README.txt"
	(
		cd "${tmpdir}"
		zip -q "${ROOT_DIR}/godot/build/android/DogeKartClash.apk" README.txt
	)
	rm -rf "${tmpdir}"
fi

echo "Android artifact: ${ROOT_DIR}/godot/build/android/DogeKartClash.apk"
EOF

cat > "${ROOT_DIR}/scripts/serve_web_from_pup.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${PORT:-8080}"
cd "${ROOT_DIR}/pup/www"
python3 -m http.server "${PORT}"
EOF

cat > "${ROOT_DIR}/scripts/dogecoin_cli_tools.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LIBDOGE_DIR="${ROOT_DIR}/third_party/libdogecoin"
SPVNODE_BIN="${SPVNODE_BIN:-spvnode}"
SENDTX_BIN="${SENDTX_BIN:-sendtx}"

usage() {
	echo "Usage:"
	echo "  $0 status"
	echo "  $0 spvnode [extra args...]"
	echo "  $0 sendtx <raw_tx_hex>"
}

case "${1:-}" in
	status)
		echo "libdogecoin source: ${LIBDOGE_DIR}"
		command -v "${SPVNODE_BIN}" >/dev/null 2>&1 && echo "spvnode available: ${SPVNODE_BIN}" || echo "spvnode not found on PATH"
		command -v "${SENDTX_BIN}" >/dev/null 2>&1 && echo "sendtx available: ${SENDTX_BIN}" || echo "sendtx not found on PATH"
		;;
	spvnode)
		shift
		exec "${SPVNODE_BIN}" "$@"
		;;
	sendtx)
		shift
		if [ $# -lt 1 ]; then
			echo "sendtx requires raw transaction hex."
			exit 1
		fi
		exec "${SENDTX_BIN}" "$1"
		;;
	*)
		usage
		exit 1
		;;
esac
EOF

cat > "${ROOT_DIR}/pup/manifest.json" <<'EOF'
{
  "name": "dogekart-clash",
  "version": "0.1.0",
  "description": "DogeKart Clash backend package for Dogebox",
  "services": [
    { "name": "nakama", "port": 7350 },
    { "name": "dogecoin-rpc", "port": 18443 },
    { "name": "web", "port": 8080 }
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
    cp -r www $out/share/dogekart-clash/www
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

[preset.1]
name="Web"
platform="Web"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/web/index.html"
script_export_mode=1

[preset.1.options]
vram_texture_compression/for_desktop=true

[preset.2]
name="Android"
platform="Android"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/android/DogeKartClash.apk"
script_export_mode=1

[preset.2.options]
package/unique_name="org.dogekart.clash"
package/name="DogeKart Clash"
EOF

write_model_obj() {
	local output_path="$1"
	cat > "${output_path}" <<'EOF'
o model
v -1.2 -0.7 0.0
v 1.2 -0.7 0.0
v 1.2 0.7 0.0
v -1.2 0.7 0.0
v -1.0 -0.55 0.55
v 1.0 -0.55 0.55
v 1.0 0.55 0.55
v -1.0 0.55 0.55
v -0.8 -0.45 1.0
v 0.8 -0.45 1.0
v 0.8 0.45 1.0
v -0.8 0.45 1.0
v -0.45 -0.35 1.35
v 0.45 -0.35 1.35
v 0.45 0.35 1.35
v -0.45 0.35 1.35
f 1 2 3 4
f 1 2 6 5
f 2 3 7 6
f 3 4 8 7
f 4 1 5 8
f 5 6 10 9
f 6 7 11 10
f 7 8 12 11
f 8 5 9 12
f 9 10 14 13
f 10 11 15 14
f 11 12 16 15
f 12 9 13 16
f 13 14 15 16
EOF
}

write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_01.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_02.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_03.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_04.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_05.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_06.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_07.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_08.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_09.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_10.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_11.obj"
write_model_obj "${ROOT_DIR}/assets/models/karts/shiba_kart_12.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/moon_loop_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/doge_city_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/shiba_temple_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/wow_valley_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/to_the_moon_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/shibaverse_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/boneyard_ring_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/tracks/wow_speedway_track.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/shiba_fighter.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/doge_knight_fighter.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/moon_monk_fighter.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/rocket_rider_fighter.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/pixel_shiba_fighter.obj"
write_model_obj "${ROOT_DIR}/assets/models/fighters/dojo_guardian_fighter.obj"

chmod +x "${ROOT_DIR}/scripts/link_addons.sh" "${ROOT_DIR}/scripts/dev_up.sh" "${ROOT_DIR}/scripts/generate_models.sh" "${ROOT_DIR}/scripts/build_executable.sh" "${ROOT_DIR}/scripts/build_pup.sh" "${ROOT_DIR}/scripts/build_web_bundle.sh" "${ROOT_DIR}/scripts/build_android_apk.sh" "${ROOT_DIR}/scripts/serve_web_from_pup.sh" "${ROOT_DIR}/scripts/dogecoin_cli_tools.sh"

echo "DogeKart Clash scaffold created at: ${ROOT_DIR}"
