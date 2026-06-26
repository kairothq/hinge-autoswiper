#!/usr/bin/env bash
# ABOUTME: One-shot installer for hinge-autoswiper. Sets up mirroir (iPhone control),
# ABOUTME: Goose (the agent), and the LLM brain (local Ollama/Gemma or a cloud provider).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
say()  { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
ok()   { printf "  \033[1;32mOK\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m!!\033[0m %s\n" "$*"; }
die()  { printf "\n\033[1;31mERROR: %s\033[0m\n" "$*" >&2; exit 1; }

# --- 0. Load config ---------------------------------------------------------
if [[ ! -f "$HERE/.env" ]]; then
  cp "$HERE/.env.example" "$HERE/.env"
  warn "Created .env from .env.example — edit it to pick your model, then re-run."
fi
set -a; source "$HERE/.env"; set +a
: "${GOOSE_PROVIDER:=ollama}"; : "${GOOSE_MODEL:=gemma3:4b}"; : "${OLLAMA_HOST:=http://localhost:11434}"

# --- 1. Platform guard ------------------------------------------------------
say "Checking platform"
[[ "$(uname)" == "Darwin" ]] || die "macOS only (iPhone Mirroring is a macOS feature)."
OSVER="$(sw_vers -productVersion)"; OSMAJ="${OSVER%%.*}"
(( OSMAJ >= 15 )) || die "Need macOS 15+ (Sequoia) for iPhone Mirroring. You have $OSVER."
ok "macOS $OSVER"
command -v brew >/dev/null || die "Homebrew required: https://brew.sh"
command -v node >/dev/null || die "Node.js required (brew install node)."
ok "brew + node present"

# --- 2. mirroir (iPhone control MCP server) ---------------------------------
say "Installing mirroir-mcp (iPhone control)"
if command -v mirroir-mcp >/dev/null; then ok "mirroir-mcp already installed"
else npm install -g mirroir-mcp@latest >/dev/null 2>&1 && ok "installed mirroir-mcp"; fi
mkdir -p "$HOME/.mirroir-mcp/skills" "$HOME/.mirroir-mcp/models"
cp "$HERE/config/permissions.json" "$HOME/.mirroir-mcp/permissions.json"
cp "$HERE/config/hinge-app.md"     "$HOME/.mirroir-mcp/skills/hinge-app.md"
ok "wrote permissions.json + Hinge skill"

# --- 3. Goose (the agent runtime) -------------------------------------------
say "Installing Goose (agent runtime)"
if command -v goose >/dev/null; then ok "goose already installed"
else
  curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | CONFIGURE=false bash >/dev/null 2>&1 || true
  export PATH="$HOME/.local/bin:$PATH"
  command -v goose >/dev/null || die "Goose install failed. See https://block.github.io/goose/"
  ok "installed goose"
fi

# --- 4. The brain (LLM provider) --------------------------------------------
if [[ "$GOOSE_PROVIDER" == "ollama" ]]; then
  say "Setting up local model via Ollama ($GOOSE_MODEL)"
  command -v ollama >/dev/null || { brew install ollama >/dev/null 2>&1 && ok "installed ollama"; }
  pgrep -x ollama >/dev/null || { nohup ollama serve >/tmp/ollama.log 2>&1 & sleep 3; }
  ok "ollama server running"
  RAM_GB=$(( $(sysctl -n hw.memsize) / 1073741824 ))
  if (( RAM_GB < 16 )) && [[ "$GOOSE_MODEL" == gemma3:1[0-9]b || "$GOOSE_MODEL" == gemma3:2*b ]]; then
    warn "Only ${RAM_GB}GB RAM — $GOOSE_MODEL may not fit. gemma3:4b is the safe choice here."
  fi
  say "Pulling $GOOSE_MODEL (this can be several GB)"
  ollama pull "$GOOSE_MODEL" && ok "model ready"
else
  say "Using cloud provider: $GOOSE_PROVIDER ($GOOSE_MODEL)"
  warn "Make sure the matching API key is set in .env (used by run.sh)."
fi

# --- 5. Goose config --------------------------------------------------------
say "Writing Goose config"
mkdir -p "$HOME/.config/goose"
{
  echo "GOOSE_PROVIDER: $GOOSE_PROVIDER"
  echo "GOOSE_MODEL: $GOOSE_MODEL"
  [[ "$GOOSE_PROVIDER" == "ollama" ]] && echo "OLLAMA_HOST: $OLLAMA_HOST"
} > "$HOME/.config/goose/config.yaml"
ok "wrote ~/.config/goose/config.yaml"

say "Done. Next:"
cat <<EOF
  1. Open the "iPhone Mirroring" app, unlock your iPhone, keep the window LIVE (not paused).
  2. Approve the macOS Screen Recording + Accessibility prompts on first screenshot.
  3. Smoke-test the loop:   ./run.sh test     (drives YouTube, zero risk)
  4. Go live on Hinge:      ./run.sh          (opens Hinge, then run the swiper)
  Kill switch: close the iPhone Mirroring window to halt all input instantly.
EOF
