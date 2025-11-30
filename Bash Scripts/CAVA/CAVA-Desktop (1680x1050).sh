#!/bin/bash

# --- USER CONFIGURATIONS ---

PROFILE="CAVA"                # GNOME Terminal profile (configure transparency, etc.)
DELAY=1.0                     # Delay (seconds) to allow terminal to spawn
WIDTH=1700                    # Default window width
HEIGHT=400                    # Default window height
WORKSPACE=0                   # Default workspace (0 = first)
POSITION="custom"             # Options: center, top, bottom, left, right, custom
CUSTOM_X=4                 # Custom X (if POSITION="custom")
CUSTOM_Y=620                  # Custom Y
TERMINAL_TITLE="CAVA"         # Used to identify the terminal window
TARGET_MONITOR="primary"      # Options: primary, left, right, specific (e.g., HDMI-1)

# --- VISIBILITY SETTINGS ---
# Modes:
#   "single"   → visible on one workspace (WORKSPACE)
#   "all"      → visible on all workspaces
#   "custom"   → visible on selected workspaces (see SELECTED_WORKSPACES below)
VISIBILITY_MODE="single"

# List of workspace numbers (0-indexed) where CAVA should appear if VISIBILITY_MODE="custom"
SELECTED_WORKSPACES=(0 2 4)

# =====================================================


# --- FUNCTION: Get window ID of CAVA terminal ---
get_cava_window() {
  xdotool search --name "$TERMINAL_TITLE" | tail -n 1
}

# --- FUNCTION: Detect monitor geometry (uses xrandr) ---
get_monitor_geometry() {
  # Detect connected monitors
  MONITORS=($(xrandr --query | grep " connected" | awk '{print $1}'))
  PRIMARY=$(xrandr --query | grep " primary" | awk '{print $1}')

  if [[ "$TARGET_MONITOR" == "primary" ]]; then
    MONITOR="$PRIMARY"
  elif [[ "$TARGET_MONITOR" == "left" ]]; then
    MONITOR="${MONITORS[0]}"
  elif [[ "$TARGET_MONITOR" == "right" && ${#MONITORS[@]} -gt 1 ]]; then
    MONITOR="${MONITORS[1]}"
  else
    MONITOR="$TARGET_MONITOR"
  fi

  # Get monitor geometry: X Y WIDTH HEIGHT
  GEOMETRY=$(xrandr --query | grep -A1 "^$MONITOR " | grep -oP '\d+x\d+\+\d+\+\d+' | head -n1)
  MON_WIDTH=$(echo "$GEOMETRY" | cut -d'x' -f1)
  MON_HEIGHT=$(echo "$GEOMETRY" | cut -d'x' -f2 | cut -d'+' -f1)
  MON_X=$(echo "$GEOMETRY" | cut -d'+' -f2)
  MON_Y=$(echo "$GEOMETRY" | cut -d'+' -f3)
}

# --- FUNCTION: Calculate position based on POSITION ---
calculate_position() {
  case "$POSITION" in
    "center")
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
    "top")
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$MON_Y
      ;;
    "bottom")
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$(( MON_Y + MON_HEIGHT - HEIGHT ))
      ;;
    "left")
      X=$MON_X
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
    "right")
      X=$(( MON_X + MON_WIDTH - WIDTH ))
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
    "custom")
      X=$CUSTOM_X
      Y=$CUSTOM_Y
      ;;
    *)
      echo "⚠️ Invalid POSITION '$POSITION'. Defaulting to center."
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
  esac
}

# --- FUNCTION: Launch CAVA ---
launch_cava() {
  echo "🚀 Launching CAVA on monitor '$MONITOR'..."
  gnome-terminal --window-with-profile="$PROFILE" --title="$TERMINAL_TITLE" -- bash -c "cava; exec bash" &
  sleep $DELAY

  WIN_ID=$(get_cava_window)
  if [[ -z "$WIN_ID" ]]; then
    echo "❌ Could not detect CAVA window. Exiting."
    exit 1
  fi

  wmctrl -ir "$WIN_ID" -t $WORKSPACE
  wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager
  wmctrl -ir "$WIN_ID" -b remove,maximized_vert,maximized_horz

  calculate_position
  wmctrl -ir "$WIN_ID" -e 0,$X,$Y,$WIDTH,$HEIGHT

  # Convert to desktop-type window
  xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
        -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"

  # Set workspace visibility
  case "$VISIBILITY_MODE" in
    "all")
      wmctrl -ir "$WIN_ID" -b add,sticky
      echo "🌍 CAVA set to appear on all workspaces."
      ;;
    "custom")
      wmctrl -ir "$WIN_ID" -b remove,sticky
      echo "🎯 CAVA set to appear on selected workspaces: ${SELECTED_WORKSPACES[*]}"
      for ws in "${SELECTED_WORKSPACES[@]}"; do
        wmctrl -ir "$WIN_ID" -t $ws
      done
      ;;
    "single" | *)
      wmctrl -ir "$WIN_ID" -b remove,sticky
      wmctrl -ir "$WIN_ID" -t $WORKSPACE
      echo "🖥️ CAVA restricted to workspace $((WORKSPACE+1))."
      ;;
  esac

  # Keep behind other windows
  xdotool windowlower "$WIN_ID"

  echo "✅ CAVA visualizer placed at $POSITION on $MONITOR."
}

# --- FUNCTION: Close CAVA ---
close_cava() {
  echo "🧹 Closing CAVA..."
  pkill -f "cava"
  sleep 0.3
  for win in $(xdotool search --name "$TERMINAL_TITLE" 2>/dev/null); do
    wmctrl -ic "$win"
  done
  echo "✅ CAVA closed."
}

# --- FUNCTION: Check if CAVA is running ---
is_cava_running() {
  pgrep -f "cava" >/dev/null 2>&1
}

# --- MAIN TOGGLE LOGIC ---
get_monitor_geometry

if is_cava_running; then
  close_cava
else
  launch_cava
fi

