#!/usr/bin/env bash

install_gsutil() {
  _process "Installing Google Cloud CLI (gsutil)"

  # Check if gcloud is already installed
  if command -v gcloud &> /dev/null; then
    _info "Google Cloud CLI (gcloud) is already installed"
    return 0
  fi

  # Detect architecture
  local arch=$(uname -m)
  local download_url=""
  local filename=""
  
  case $arch in
    "x86_64")
      download_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz"
      filename="google-cloud-cli-darwin-x86_64.tar.gz"
      _info "Detected Intel Mac (x86_64)"
      ;;
    "arm64")
      download_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz"
      filename="google-cloud-cli-darwin-arm.tar.gz"
      _info "Detected Apple Silicon Mac (ARM64)"
      ;;
    *)
      _warning "Unsupported architecture: $arch. Defaulting to x86_64"
      download_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz"
      filename="google-cloud-cli-darwin-x86_64.tar.gz"
      ;;
  esac

  # Create temporary directory for download
  local temp_dir=$(mktemp -d)
  local download_path="${temp_dir}/${filename}"

  _process "Downloading Google Cloud CLI from ${download_url}"
  
  if ! curl -L -o "${download_path}" "${download_url}"; then
    _warning "Failed to download Google Cloud CLI"
    rm -rf "${temp_dir}"
    return 1
  fi

  # Extract to home directory
  _process "Extracting Google Cloud CLI to ${HOME}"
  
  # Remove existing installation if it exists
  if [ -d "${HOME}/google-cloud-sdk" ]; then
    _info "Removing existing Google Cloud SDK installation"
    rm -rf "${HOME}/google-cloud-sdk"
  fi

  if ! tar -xf "${download_path}" -C "${HOME}"; then
    _warning "Failed to extract Google Cloud CLI"
    rm -rf "${temp_dir}"
    return 1
  fi

  # Clean up temporary directory
  rm -rf "${temp_dir}"

  # Run the installation script
  _process "Running Google Cloud CLI installation script"
  
  if [ -f "${HOME}/google-cloud-sdk/install.sh" ]; then
    # Run installation non-interactively with default options
    if ! "${HOME}/google-cloud-sdk/install.sh" --quiet --command-completion=true --path-update=true; then
      _warning "Google Cloud CLI installation script failed"
      return 1
    fi
  else
    _warning "Installation script not found at ${HOME}/google-cloud-sdk/install.sh"
    return 1
  fi

  # Source the updated shell configuration to get gcloud in PATH
  if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc" 2>/dev/null || true
  fi
  if [ -f "${HOME}/.zshrc" ]; then
    source "${HOME}/.zshrc" 2>/dev/null || true
  fi

  # Add to current session PATH if not already there
  if [[ ":$PATH:" != *":${HOME}/google-cloud-sdk/bin:"* ]]; then
    export PATH="${HOME}/google-cloud-sdk/bin:$PATH"
  fi

  # Verify installation
  if command -v gcloud &> /dev/null; then
    local gcloud_version=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null || echo "unknown")
    _success "Google Cloud CLI installed successfully (version: ${gcloud_version})"
    
    _info "To complete setup, run 'gcloud init' to authenticate and configure your project"
    _info "You can also run 'gsutil' commands to interact with Google Cloud Storage"
  else
    _warning "Google Cloud CLI installation completed but 'gcloud' command not found in PATH"
    _info "You may need to restart your terminal or run: source ${HOME}/.zshrc"
    return 1
  fi

  return 0
} 