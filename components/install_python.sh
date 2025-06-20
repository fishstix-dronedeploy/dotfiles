#!/bin/bash

install_python() {
  _process "→ Installing Python packages and tools"

  # Install Python 3.13.0 (latest version available)
  # init pyenv if needed
  eval "$(pyenv init -)"

  PYTHON_VERSION="3.13.0"
  _process "  → Installing Python $PYTHON_VERSION via pyenv"
  pyenv install $PYTHON_VERSION >> "$LOG" 2>&1
  pyenv shell $PYTHON_VERSION >> "$LOG" 2>&1
  pyenv global $PYTHON_VERSION >> "$LOG" 2>&1

  # Verify installation
  _process "  → Verifying Python $PYTHON_VERSION installation: $(python3 --version)"
  if python3 --version | grep -q "Python $PYTHON_VERSION"; then
    _success "Python $PYTHON_VERSION installed and set as global version"
  else
    _warning "Failed to install or set Python $PYTHON_VERSION as shell version"
    return 1
  fi

  # Check if pip3 is available
  if ! command -v pip3 > /dev/null; then
    _process "  → Installing pip3"
    case "${package_manager}" in
      apt-get)
        sudo apt-get install -y python3-pip >> "$LOG" 2>&1
        ;;
      dnf)
        sudo dnf install -y python3-pip >> "$LOG" 2>&1
        ;;
      pacman)
        sudo pacman -S --noconfirm python-pip >> "$LOG" 2>&1
        ;;
      zypper)
        sudo zypper install -y python3-pip >> "$LOG" 2>&1
        ;;
      pkg)
        pkg install -y py3-pip >> "$LOG" 2>&1
        ;;
      apk)
        apk add --no-cache py3-pip >> "$LOG" 2>&1
        ;;
      brew)
        # pip3 should already be available with brew python3
        _process "  → pip3 should be available via brew python3"
        ;;
      *)
        _warning "Could not install pip3 automatically. Please install it manually."
        return 1
        ;;
    esac
  fi

  # Define array of Python packages to install
  python_packages=(
    "pip --upgrade"
    "pre-commit"
    "pipenv"
    "black"
    "flake8"
    "pytest"
    "requests"
    "click"
    "setuptools wheel"
    "virtualenv"
    "poetry"
    "uv"
    "certifi"
  )

  # Install each package
  for package in "${python_packages[@]}"; do
    _process "  → Installing ${package}"
    python3 -m pip install --user ${package} >> "$LOG" 2>&1
  done
} 