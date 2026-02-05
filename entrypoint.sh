#!/bin/bash
set -e

echo Activate the virtual environment
source /app/comfyui_env/bin/activate

echo "Building setuptools wheel..."
pip install --upgrade pip setuptools wheel

echo "Checking for custom node requirements..."
if [ -d "/app/custom_nodes" ]; then
  find /app/custom_nodes -name "requirements.txt" -exec pip install --no-cache-dir -r {} \;
fi

echo "Starting ComfyUI..."
exec python3 main.py --listen 0.0.0.0 --lowvram --async-offload --reserve-vram 1.0 "$@"
