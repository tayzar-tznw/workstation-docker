FROM asia-northeast1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

# Install Python, venv, git, and Python build dependencies
RUN apt-get update && apt-get install -y \
    python3-venv \
    make

# Create a global virtual environment using the system python
RUN python3 -m venv /opt/global-venv

# Install uv into the global virtual environment
RUN /opt/global-venv/bin/pip install uv

# Activate the global venv for all users by default and install project packages
ENV VIRTUAL_ENV="/opt/global-venv"
# Prepend venv's bin to the PATH
ENV PATH="/opt/global-venv/bin:${PATH}"

# Copy project files and install dependencies
COPY pyproject.toml /app/pyproject.toml
COPY requirements.txt /app/requirements.txt
WORKDIR /app
# Install dependencies from requirements.txt into the active venv
# uv is now in PATH from /opt/global-venv/bin/uv
RUN uv pip install -r requirements.txt
# RUN uv pip install .

# Install Python Extension
RUN wget https://open-vsx.org/api/ms-python/python/2025.4.0/file/ms-python.python-2025.4.0.vsix \
  && unzip ms-python.python-2025.4.0.vsix "extension/*" \
  && mv extension /opt/code-oss/extensions/ms-python

RUN rm -rf extension

# Install Jupyter Extension
RUN wget https://open-vsx.org/api/ms-toolsai/jupyter/2025.5.0/file/ms-toolsai.jupyter-2025.5.0.vsix \
  && unzip ms-toolsai.jupyter-2025.5.0.vsix "extension/*" \
  && mv extension /opt/code-oss/extensions/ms-toolsai

RUN rm -rf extension

# Copy custom-paths.sh to the startup scripts directory and make it executable
COPY custom-paths.sh /etc/workstation-startup.d/210-custom-paths.sh
RUN chmod +x /etc/workstation-startup.d/210-custom-paths.sh



