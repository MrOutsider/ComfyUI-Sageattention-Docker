# Use the requested Debian Trixie Slim base
FROM debian:trixie-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 1. Enable Non-Free Repositories & Install System Dependencies
# We MUST patch the sources to enable 'non-free' and 'contrib' to find nvidia-cuda-toolkit
RUN sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources \
  && apt-get update && apt-get install -y \
  git \
  wget \
  python3 \
  python3-venv \
  python3-pip \
  findutils \
  # Now available after enabling non-free
  nvidia-cuda-toolkit \
  ninja-build \
# Multimedia & Graphics
  ffmpeg \
  libgl1 \
  libglib2.0-0 \
  libsm6 \
  libxext6 \
# Build tools
  build-essential \
  python3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 2. Clone ComfyUI
RUN git clone https://github.com/Comfy-Org/ComfyUI .

# 3. Setup Virtual Environment
RUN python3 -m venv /app/comfyui_env
ENV PATH="/app/comfyui_env/bin:$PATH"

# 4. Install Core Requirements
# Installs PyTorch with CUDA 13.0 support
RUN pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130

# 5. Install Triton and SageAttention
RUN pip install --no-cache-dir triton
# We use --no-build-isolation so it uses the 'torch' we just installed above
RUN pip install --no-cache-dir --no-build-isolation sageattention

RUN pip install --no-cache-dir -r requirements.txt

# 6. Setup Entrypoint Script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8188

ENTRYPOINT ["/entrypoint.sh"]
