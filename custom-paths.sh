#!/bin/bash

# Add global venv to PATH so uv and other tools are available
export PATH="/opt/global-venv/bin:${PATH}"

# Add user's .local/bin to PATH (for any tools installed by user at runtime)
export PATH="/home/user/.local/bin:${PATH}" 
