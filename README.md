# ComfyUI-Sageattention-Docker

A high-performance Dockerized implementation of **ComfyUI** pre-configured with **SageAttention**. This container is optimized for modern NVIDIA GPUs (RTX 50-series) to provide significant speedups in image and video generation workflows.

![The image depicts a futuristic, high-tech server room with a large, transparent, blue-lit server in the center. The server is shaped like a cube and has a whale logo on its front, surrounded by various screens displaying different information from ComfyUI.](comfyui.png)

---

## Features

* **SageAttention Integration:** Achieve speedups compared to FlashAttention using quantized attention mechanisms without losing end-to-end metrics.
* **Persistent Storage:** Mounted volumes for models, output, and custom nodes to ensure your data persists across container restarts.

---

## Prerequisites

Before you begin, ensure you have the following installed on your host system:

* **NVIDIA Driver:** Version 535+ (Recommended 550+ for Blackwell/50-series).
* **Docker:** [Install Docker](https://docs.docker.com/get-docker/)
* **NVIDIA Container Toolkit:** (Crucial for GPU passthrough).

---

## Project Structure

```text
.
├── Dockerfile              # Builds the optimized image with SageAttention
├── docker-compose.yml      # Orchestration for the container and volumes
├── entrypoint.sh           # Initialization and launch script
└── data/                   # Main data directory (Mapped to /app/ in container)
    ├── models/             # Place your checkpoints, LoRAs, and VAEs here
    ├── custom_nodes/       # Install community nodes here
    ├── input/              # Source images for Img2Img workflows
    ├── output/             # Your generated images and videos
    └── user/               # User-specific settings and browser data
