#!/usr/bin/env bash
# ABOUTME: Launches the swiper. "./run.sh test" runs the safe YouTube smoke test;
# ABOUTME: "./run.sh" runs the Hinge auto-swiper using settings from .env.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
say()  { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
warn() { printf "  \033[1;33m!!\033[0m %s\n" "$*"; }
die()  { printf "\n\033[1;31mERROR: %s\033[0m\n" "$*" >&2; exit 1; }

[[ -f "$HERE/.env" ]] || die "No .env — run ./install.sh first."
set -a; source "$HERE/.env"; set +a
export PATH="$HOME/.local/bin:$PATH"
command -v goose >/dev/null || die "goose not found — run ./install.sh first."

# Ensure the local model server is up when using ollama.
if [[ "${GOOSE_PROVIDER:-ollama}" == "ollama" ]]; then
  pgrep -x ollama >/dev/null || { nohup ollama serve >/tmp/ollama.log 2>&1 & sleep 3; }
fi

# Warn (don't block) if iPhone Mirroring isn't running.
pgrep -f "iPhone Mirroring" >/dev/null || \
  warn "iPhone Mirroring doesn't look open. Open it, unlock the phone, keep it LIVE."

ACTION="${1:-hinge}"   # "test" = YouTube smoke test, anything else = Hinge swiper

if [[ "$ACTION" == "test" ]]; then
  say "Running YouTube smoke test (open YouTube on the mirrored phone first)"
  exec goose run --recipe "$HERE/recipes/youtube-test.yaml"
fi

say "Running Hinge auto-swiper  (behaviour mode=${MODE:-like_only})"
warn "Automating Hinge violates its ToS; accounts can be flagged. Cautious pacing on."
exec goose run --recipe "$HERE/recipes/hinge.yaml" \
  --params "mode=${MODE:-like_only}" \
  --params "session_cap=${SESSION_CAP:-40}" \
  --params "min_delay=${MIN_DELAY:-3}" \
  --params "max_delay=${MAX_DELAY:-8}" \
  --params "warmup=${WARMUP:-true}" \
  --params "dealbreakers=${DEALBREAKERS:-none}"
