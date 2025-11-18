#!/bin/bash
# MPV Video Wallpaper (Dual-Monitor / Multi-Workspace, Uninteractable)

VIDEO="$1"                # Path to video file, e.g. ./wallpaper.sh /path/to/video.mp4
DELAY=1.0                 # Wait time before configuring window (in seconds)
WIDTH=""                  # Leave empty for auto, or set manually (e.g. WIDTH=1920)
HEIGHT=""                 # Leave empty for auto, or set manually (e.g. HEIGHT=1080)
WORKSPACE=0               # Workspace index to show wallpaper on (used if VISIBILITY_MODE="single")
POSITION="center"         # Position on screen: center | top | bottom | left | right | custom
CUSTOM_X=-104             # Custom X position (used if POSITION="custom")
CUSTOM_Y=338              # Custom Y position (used if POSITION="custom")
TARGET_MONITOR="primary"  # Target monitor: primary | left | right | <monitor_name from xrandr>
VISIBILITY_MODE="single"  # Workspace visibility: single | all

# Validate video file
if [ ! -f "$VIDEO" ]; then
    echo "Usage: $0 /path/to/video.mp4"
    exit 1
fi

get_monitor_geometry() {
    MONITORS=($(xrandr --query | grep " connected" | awk '{print $1}'))
    PRIMARY=$(xrandr --query | grep " primary" | awk '{print $1}')

    case "$TARGET_MONITOR" in
        primary) MONITOR="$PRIMARY" ;;
        left)    MONITOR="${MONITORS[0]}" ;;
        right)   MONITOR="${MONITORS[1]:-${MONITORS[0]}}" ;;
        *)       MONITOR="$TARGET_MONITOR" ;;
    esac

    GEOMETRY=$(xrandr --query | grep -A1 "^$MONITOR " | grep -oP '\d+x\d+\+\d+\+\d+' | head -n1)
    MON_WIDTH=$(echo "$GEOMETRY" | cut -d'x' -f1)
    MON_HEIGHT=$(echo "$GEOMETRY" | cut -d'x' -f2 | cut -d'+' -f1)
    MON_X=$(echo "$GEOMETRY" | cut -d'+' -f2)
    MON_Y=$(echo "$GEOMETRY" | cut -d'+' -f3)

    # Auto-detect if not set manually
    [ -z "$WIDTH" ] && WIDTH=$MON_WIDTH
    [ -z "$HEIGHT" ] && HEIGHT=$MON_HEIGHT
}

calculate_position() {
    case "$POSITION" in
        center)  X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 )); Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
        top)     X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 )); Y=$MON_Y ;;
        bottom)  X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 )); Y=$(( MON_Y + MON_HEIGHT - HEIGHT )) ;;
        left)    X=$MON_X; Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
        right)   X=$(( MON_X + MON_WIDTH - WIDTH )); Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
        custom)  X=$CUSTOM_X; Y=$CUSTOM_Y ;;
        *)       X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 )); Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
    esac
}

launch_video() {
    echo "🚀 Launching video wallpaper..."
    pkill -f "mpv.*wallpaper_mpv" 2>/dev/null

    mpv --loop=inf --no-audio --really-quiet \
        --no-input-default-bindings --no-osc --no-border \
        --force-window=yes --geometry=${WIDTH}x${HEIGHT}+${X}+${Y} \
        --panscan=1.0 --title="wallpaper_mpv" "$VIDEO" &

    sleep $DELAY
    WIN_ID=$(xdotool search --onlyvisible --name "wallpaper_mpv" | tail -n1)
    [ -z "$WIN_ID" ] && { echo "❌ Could not detect mpv window. Exiting."; exit 1; }

    # Place below everything, make unclickable
    wmctrl -ir "$WIN_ID" -b add,below,sticky,skip_taskbar,skip_pager
    xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"
    xprop -id "$WIN_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE "_NET_WM_STATE_BELOW"
    xprop -id "$WIN_ID" -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "2, 0, 0, 0, 0"
    xprop -id "$WIN_ID" -remove WM_NAME
    xprop -id "$WIN_ID" -remove WM_CLASS
    xprop -id "$WIN_ID" -remove WM_HINTS

    # Limit visibility per workspace
    case "$VISIBILITY_MODE" in
        all) wmctrl -ir "$WIN_ID" -b add,sticky ;;
        single|*) wmctrl -ir "$WIN_ID" -t $WORKSPACE ;;
    esac

    echo "✅ Video wallpaper running (uninteractable)."
    echo "Stop with: pkill -f wallpaper_mpv"
}

close_video() {
    echo "🧹 Closing video wallpaper..."
    pkill -f "mpv.*wallpaper_mpv"
    echo "✅ Video wallpaper stopped."
}

is_video_running() {
    pgrep -f "mpv.*wallpaper_mpv" >/dev/null 2>&1
}

get_monitor_geometry
calculate_position

if is_video_running; then
    close_video
else
    launch_video
fi

