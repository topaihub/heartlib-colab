#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/content/heartlib-colab"
HEARTLIB_DIR="/content/heartlib"
CKPT_DIR="/content/ckpt"

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v git-lfs >/dev/null 2>&1; then
  apt-get update
  apt-get install -y git-lfs
fi

git lfs install

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

HEARTCODEC_REPO="HeartMuLa/HeartCodec-oss-20260123"

download_hf() {
  local repo_id="$1"
  local local_dir="$2"
  uv run hf download --local-dir "$local_dir" "$repo_id"
}

download_modelscope() {
  local model_id="$1"
  local local_dir="$2"
  uv run python -m modelscope.cli.cli download --model "$model_id" --local_dir "$local_dir"
}

clone_hf_model_repo() {
  local repo_id="$1"
  local local_dir="$2"
  git clone "https://huggingface.co/$repo_id" "$local_dir"
}

download_with_fallback() {
  local hf_repo="$1"
  local modelscope_repo="$2"
  local local_dir="$3"
  local marker_path="$4"

  if [ -e "$marker_path" ]; then
    return 0
  fi

  echo "Downloading $hf_repo -> $local_dir"
  if download_hf "$hf_repo" "$local_dir"; then
    return 0
  fi

  echo "Hugging Face download failed for $hf_repo. Falling back to ModelScope..."
  download_modelscope "$modelscope_repo" "$local_dir"
}

download_modelscope_only() {
  local model_id="$1"
  local local_dir="$2"
  local marker_path="$3"

  if [ -e "$marker_path" ]; then
    return 0
  fi

  echo "Downloading $model_id from ModelScope -> $local_dir"
  download_modelscope "$model_id" "$local_dir"
}

download_heartcodec() {
  local local_dir="$1"
  local marker_path="$2"

  if [ -e "$marker_path" ]; then
    return 0
  fi

  echo "Downloading $HEARTCODEC_REPO from Hugging Face -> $local_dir"
  if download_hf "$HEARTCODEC_REPO" "$local_dir"; then
    return 0
  fi

  echo "Hugging Face API download failed for $HEARTCODEC_REPO. Cloning Hugging Face model repo..."
  clone_hf_model_repo "$HEARTCODEC_REPO" "$local_dir"
}

download_with_fallback "HeartMuLa/HeartMuLaGen" "HeartMuLa/HeartMuLaGen" "$CKPT_DIR" "$CKPT_DIR/tokenizer.json"
download_with_fallback "HeartMuLa/HeartMuLa-oss-3B" "HeartMuLa/HeartMuLa-oss-3B" "$CKPT_DIR/HeartMuLa-oss-3B" "$CKPT_DIR/HeartMuLa-oss-3B"
download_heartcodec "$CKPT_DIR/HeartCodec-oss" "$CKPT_DIR/HeartCodec-oss"

echo "Setup complete."
