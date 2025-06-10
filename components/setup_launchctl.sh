#!/bin/bash

setup_launchctl() {
  _process "→ Setting up launchctl services"

  # Get list of currently loaded services
  loaded_services=$(launchctl list 2>/dev/null)

  # Define array of services to load
  declare -A services=(
    ["com.dronedeploy.ollama"]="ollama_boot.plist"
    ["com.koekeishiya.skhd"]="com.koekeishiya.skhd.plist"
  )

  # Loop through services and load them if needed
  for service_name in "${!services[@]}"; do
    plist_file="${services[$service_name]}"
    if ! echo "$loaded_services" | grep -q "$service_name"; then
      _process "  → Loading ${service_name} service"
      if [ -f ~/Library/LaunchAgents/"$plist_file" ]; then
        launchctl load ~/Library/LaunchAgents/"$plist_file" >> "$LOG" 2>&1
        if [ $? -eq 0 ]; then
          _success "${service_name} service loaded successfully"
        else
          _warning "Failed to load ${service_name} service"
        fi
      else
        _warning "${plist_file} not found in ~/Library/LaunchAgents/"
      fi
    else
      _info "${service_name} service is already loaded"
    fi
  done


  _success "launchctl services setup completed"
} 