#!/bin/bash

function install_nerdfont() {
  _process "→ Installing JetBrains Mono Nerd Font"

  # Create the fonts directory if it doesn't exist
  mkdir -p ~/.local/share/fonts

  # Download and install the nerd font
  wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
  && cd ~/.local/share/fonts \
  && unzip JetBrainsMono.zip \
  && rm JetBrainsMono.zip \
  && fc-cache -fv >> "$LOG" 2>&1

  if [ $? -eq 0 ]; then
    _success "JetBrains Mono Nerd Font installed successfully"
  else
    _warning "Failed to install JetBrains Mono Nerd Font"
    return 1
  fi
} 