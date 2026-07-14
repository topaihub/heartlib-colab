#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/content/heartlib-colab"
HEARTLIB_DIR="/content/heartlib"
CKPT_DIR="/content/ckpt"

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

python -m pip install --upgrade pip

if [ ! -d "$ROOT_DIR/.git" ] && [ ! -f "$ROOT_DIR/pyproject.toml" ]; then
  echo "Expected project files under $ROOT_DIR"
  exit 1
fi

cd "$ROOT_DIR"
uv sync

if [ ! -d "$HEARTLIB_DIR/.git" ]; then
  git clone https://github.com/HeartMuLa/heartlib.git "$HEARTLIB_DIR"
fi

uv pip install -e "$HEARTLIB_DIR"

mkdir -p "$CKPT_DIR"

if [ ! -f "$CKPT_DIR/tokenizer.json" ] || [ ! -f "$CKPT_DIR/gen_config.json" ]; then
  uv run hf download --local-dir "$CKPT_DIR" "HeartMuLa/HeartMuLaGen"
fi

if [ ! -d "$CKPT_DIR/HeartMuLa-oss-3B" ]; then
  uv run hf download --local-dir "$CKPT_DIR/HeartMuLa-oss-3B" "HeartMuLa/HeartMuLa-oss-3B"
fi

if [ ! -d "$CKPT_DIR/HeartCodec-oss" ]; then
  uv run hf download --local-dir "$CKPT_DIR/HeartCodec-oss" "HeartMuLa/HeartCodec-oss"
fi

echo "Setup complete."
