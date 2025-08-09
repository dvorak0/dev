#!/usr/bin/env bash
set -euo pipefail

# ===== Hard-coded GitHub source (edit these) =====
GITHUB_OWNER="dvorak0"
GITHUB_REPO="dev"
GITHUB_REF="main"   # branch, tag, or commit SHA
REMOTE_BASE="https://raw.githubusercontent.com/${GITHUB_OWNER}/${GITHUB_REPO}/${GITHUB_REF}"

# ===== Helpers =====
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
err(){  printf "\033[1;31m[ERR ]\033[0m %s\n"  "$*"; }
need(){ command -v "$1" >/dev/null 2>&1 || { err "Missing: $1"; exit 1; } }
get(){
  # get <remote_path> <local_path>
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${REMOTE_BASE}/$1" -o "$2"
  else
    wget -q "${REMOTE_BASE}/$1" -O "$2"
  fi
}

# ===== Preflight =====
need docker
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  err "Need curl or wget"; exit 1
fi

# ===== Layout: create local dev/ and pull files from repo ROOT =====
mkdir -p dev
info "Downloading build/run scripts and Dockerfile into ./dev ..."
get "build.sh"      "dev/build.sh"
get "run.sh"        "dev/run.sh"
get "Dockerfile"    "dev/Dockerfile"

chmod +x dev/build.sh dev/run.sh

# ===== Build & run =====
info "Building Docker image ..."
./dev/build.sh
info "Starting dev container ..."
exec ./dev/run.sh

