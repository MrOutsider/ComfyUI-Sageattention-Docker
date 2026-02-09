FROM debian:trixie-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Define a variable for the ComfyUI tag
ARG COMFYUI_TAG=v0.12.3

# Enable Non-Free Repositories & Install System Dependencies
# You MUST patch the sources to enable 'non-free' and 'contrib' to find nvidia-cuda-toolkit
RUN sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources \
  && apt-get update && apt-get install -y \
  git \
  wget \
  python3 \
  python3-venv \
  python3-pip \
  findutils \
  nvidia-cuda-toolkit \
  ninja-build \
  ffmpeg \
  libgl1 \
  libglib2.0-0 \
  libsm6 \
  libxext6 \
  build-essential \
  python3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create User
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -m appuser

# Copy Entrypoint with correct ownership
COPY --chown=appuser:appuser entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create /app directory and assign ownership to appuser
RUN mkdir -p /app && chown appuser:appuser /app

# --------------------------------------------------------
# SWITCH TO USER 1000
# All commands below this line will run as 'appuser'
# --------------------------------------------------------
USER 1000
WORKDIR /app

# Validate the tag input (basic validation)
RUN if [[ ! $COMFYUI_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "Invalid tag format"; exit 1; fi

# Clone ComfyUI
RUN git clone https://github.com/Comfy-Org/ComfyUI . && \
git checkout $COMFYUI_TAG

# Setup Virtual Environment
RUN python3 -m venv /app/comfyui_env
ENV PATH="/app/comfyui_env/bin:$PATH"

# Install Core Requirements
# Installs PyTorch with CUDA 13.0 support
RUN pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130

# Install Triton and SageAttention
RUN pip install --no-cache-dir triton
# We use --no-build-isolation so it uses the 'torch' we just installed above
RUN pip install --no-cache-dir --no-build-isolation sageattention

# Install requirements for ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8188
ENTRYPOINT ["/entrypoint.sh"]
