#!/bin/bash

install_python() {
  _process "→ Installing Python packages and tools"

  # Install Python 3.13.0a4 (latest alpha version available)
  _process "  → Installing Python 3.13.0a4 via pyenv"
  pyenv install 3.13.0a4 >> "$LOG" 2>&1
  pyenv global 3.13.0a4 >> "$LOG" 2>&1

  # Verify installation
  if python3 --version | grep -q "Python 3.13"; then
    _success "Python 3.13 installed and set as global version"
  else
    _warning "Failed to install or set Python 3.13 as global version"
    return 1
  fi

  # Check if python3 is available
  if ! command -v python3 > /dev/null; then
    _warning "Python3 is not installed. Please install Python3 first."
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
  )

  # Install each package
  for package in "${python_packages[@]}"; do
    _process "  → Installing ${package}"
    python3 -m pip install --user ${package} >> "$LOG" 2>&1
  done
} 