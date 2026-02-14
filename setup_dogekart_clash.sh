#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-DogeKartClash}"
SKIP_CLONE="${SKIP_CLONE:-0}"

mkdir -p "${ROOT_DIR}"/{godot,pup,docs,assets,scripts,third_party}

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
# DogeKart Clash bootstrap

This scaffold is generated from the root `setup_dogekart_clash.sh` script and provides:

- `godot/` for the playable project.
- `pup/` for Dogebox packaging (`pup.nix`, `manifest.json`).
- `assets/` for Blender exports.
- `scripts/` for deploy/test helpers.
- `third_party/` for required upstream dependencies.

The script clones all required upstream repositories listed in the issue prompt so integration can proceed in the required order.
EOF

echo "DogeKart Clash scaffold created at: ${ROOT_DIR}"
