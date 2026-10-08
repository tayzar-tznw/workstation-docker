FROM asia-northeast1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

# Install system dependencies and Terraform
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3-venv \
    make \
    jq \
    gnupg \
    software-properties-common \
    curl \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y terraform \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a global virtual environment and install Python packages
RUN python3 -m venv /opt/global-venv \
    && /opt/global-venv/bin/pip install --no-cache-dir uv \
    && /opt/global-venv/bin/pip install --no-cache-dir --upgrade agent-starter-pack

# Activate the global venv for all users by default and install project packages
ENV VIRTUAL_ENV="/opt/global-venv"
# Prepend venv's bin to the PATH
ENV PATH="/opt/global-venv/bin:${PATH}"

# Install VSCode Extensions
RUN mkdir -p /tmp/extensions \
    && cd /tmp/extensions \
    # Remove pre-installed Gemini Code Assist extension
    && rm -rf /opt/code-oss/extensions/google.geminicodeassist \
    # Python Extension
    && wget -q https://open-vsx.org/api/ms-python/python/2026.4.0/file/ms-python.python-2026.4.0.vsix \
    && unzip -q ms-python.python-2026.4.0.vsix "extension/*" \
    && mv extension /opt/code-oss/extensions/ms-python \
    && rm -rf extension ms-python.python-2026.4.0.vsix \
    # Jupyter Extension
    && wget -q https://open-vsx.org/api/ms-toolsai/jupyter/2025.9.1/file/ms-toolsai.jupyter-2025.9.1.vsix \
    && unzip -q ms-toolsai.jupyter-2025.9.1.vsix "extension/*" \
    && mv extension /opt/code-oss/extensions/ms-toolsai \
    && rm -rf extension ms-toolsai.jupyter-2025.9.1.vsix \
    # Terraform Extension
    && wget -q https://open-vsx.org/api/hashicorp/terraform/linux-x64/2.40.0/file/hashicorp.terraform-2.40.0@linux-x64.vsix \
    && unzip -q hashicorp.terraform-2.40.0@linux-x64.vsix "extension/*" \
    && mv extension /opt/code-oss/extensions/hashicorp-terraform \
    && rm -rf extension hashicorp.terraform-2.40.0@linux-x64.vsix \
    # Google Antigravity Extension
    && wget -q https://open-vsx.org/api/Google/google-antigravity/1.5.0/file/Google.google-antigravity-1.5.0.vsix \
    && unzip -q Google.google-antigravity-1.5.0.vsix "extension/*" \
    && python3 -c 'with open("extension/extension.js","r") as f: s=f.read(); s=s.replace("script-src ${webview.cspSource};","script-src ${webview.cspSource} '\''unsafe-inline'\'';"); s=s.replace("<script src=\"${loadingBridgeJsUrl}\"></script>","<script>const l=acquireVsCodeApi(),m=document.getElementById(\"loading-details\"),n=document.getElementById(\"loading-error\"),q=document.getElementById(\"error-message-text\"),r=document.getElementById(\"retry-button\"),t=document.getElementById(\"loading-indicator\"),u=document.getElementById(\"host-input-container\"),v=document.getElementById(\"host-input\"),w=document.getElementById(\"host-submit-button\"),x=document.getElementById(\"host-input-message\"),y=document.getElementById(\"list-of-hosts\");r&&r.addEventListener(\"click\",()=>{l.postMessage({type:\"retry\"})});w&&w.addEventListener(\"click\",()=>{v&&l.postMessage({type:\"submitHost\",host:v.value})});window.addEventListener(\"message\",b=>{switch(b.data.type){case\"message\":n&&t&&u&&(n.style.visibility=\"hidden\",t.style.display=\"flex\",t.style.visibility=\"visible\",u.style.display=\"none\");m&&(b.data.message?(m.textContent=b.data.message,m.style.opacity=\"0.8\"):m.style.opacity=\"0\");break;case\"error\":n&&t&&u&&(n.style.visibility=\"visible\",t.style.display=\"none\",u.style.display=\"none\");q&&(b.data.error?(q.textContent=b.data.error,q.style.display=\"block\"):q.style.display=\"none\");break;default:break;}});l.postMessage({type:\"ready\"});</script>"); open("extension/extension.js","w").write(s)' \
    && mv extension /opt/code-oss/extensions/google-antigravity \
    && rm -rf extension Google.google-antigravity-1.5.0.vsix \
    && cd / \
    && rmdir /tmp/extensions

# Pre-install Antigravity CLI (agy)
RUN mkdir -p /etc/skel/.gemini/bin /home/user/.gemini/bin \
    && curl -fsSL https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.1-4582356770750464/linux-x64/cli_linux_x64.tar.gz | tar -xz -C /tmp \
    && mv /tmp/antigravity /usr/local/bin/agy \
    && chmod +x /usr/local/bin/agy \
    && ln -s /usr/local/bin/agy /etc/skel/.gemini/bin/agy \
    && ln -s /usr/local/bin/agy /home/user/.gemini/bin/agy \
    && chown -R user:user /home/user/.gemini 2>/dev/null || true

