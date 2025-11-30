#!/bin/bash
# Multi-Workspace & Command-Line Wallpaper Loader (Video/Image)
# Supports mp4/gif videos via mpv and images via feh

# ------------------------
# CONFIGURATION
# ------------------------
DELAY=1.0                # Delay between launching wallpapers
WIDTH=""                 # Width of wallpaper window (empty = full monitor)
HEIGHT=""                # Height of wallpaper window (empty = full monitor)
POSITION="center"        # center | top | bottom | left | right | custom
CUSTOM_X=0               # X position if POSITION=custom
CUSTOM_Y=0               # Y position if POSITION=custom
TARGET_MONITOR="primary" # Which monitor to target
VISIBILITY_MODE="single" # single | all (sticky)

# Workspace wallpapers (multi-workspace mode)
declare -A WALLPAPERS
WALLPAPERS[0]=""
WALLPAPERS[1]=""
WALLPAPERS[2]=""
WALLPAPERS[3]=""

# ------------------------
# CUSTOM FOLDER SUPPORT
# ------------------------
CUSTOM_FOLDER="/home/mint/Downloads/Live-Wallpapers"  # Path to folder containing wallpapers (videos/images)

# ------------------------
# FUNCTIONS
# ------------------------
close_all_wallpapers() {
    echo "🧹 Closing all wallpapers..."
    pkill -f "mpv.*wallpaper_mpv_ws"
    pkill -f "feh"
    echo "✅ All wallpapers stopped."
    exit 0
}

is_wallpaper_running() {
    pgrep -f "mpv.*wallpaper_mpv_ws" >/dev/null 2>&1 || pgrep -f "feh" >/dev/null 2>&1
}

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
    local WS="$1"
    local VIDEO="$2"

    if [ ! -f "$VIDEO" ]; then
        echo "❌ File not found: $VIDEO"
        return
    fi

    echo "🚀 Launching video for workspace $WS..."
    
    mpv --loop=inf --no-audio --really-quiet \
        --no-input-default-bindings --no-osc --no-border \
        --force-window=yes --geometry=${WIDTH}x${HEIGHT}+${X}+${Y} \
        --panscan=1.0 --title="wallpaper_mpv_ws$WS" "$VIDEO" &

    sleep $DELAY
    WIN_ID=$(xdotool search --onlyvisible --name "wallpaper_mpv_ws$WS" | tail -n1)
    [ -z "$WIN_ID" ] && { echo "❌ Could not detect mpv window for workspace $WS."; return; }

    wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager
    xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"
    xprop -id "$WIN_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE "_NET_WM_STATE_BELOW"
    xprop -id "$WIN_ID" -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "2, 0, 0, 0, 0"
    xprop -id "$WIN_ID" -remove WM_NAME
    xprop -id "$WIN_ID" -remove WM_CLASS
    xprop -id "$WIN_ID" -remove WM_HINTS

    if [ "$VISIBILITY_MODE" == "all" ]; then
        wmctrl -ir "$WIN_ID" -b add,sticky
    else
        wmctrl -ir "$WIN_ID" -t $WS
    fi

    echo "✅ Video wallpaper running on workspace $WS."
}

launch_image() {
    local IMAGE="$1"

    if [ ! -f "$IMAGE" ]; then
        echo "❌ File not found: $IMAGE"
        return
    fi

    echo "🖼 Launching image wallpaper..."
    feh --bg-scale "$IMAGE"
    echo "✅ Image wallpaper set."
}

launch_random_media() {
    local DIR="$1"
    if [ ! -d "$DIR" ]; then
        echo "❌ Directory not found: $DIR"
        return 1
    fi

    FILES=($(find "$DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.gif" \)))
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "❌ No .mp4 or .gif files found in $DIR"
        return 1
    fi

    RANDOM_FILE="${FILES[RANDOM % ${#FILES[@]}]}"
    launch_video "single" "$RANDOM_FILE"
}

# ------------------------
# MAIN
# ------------------------
if is_wallpaper_running; then
    close_all_wallpapers
fi

get_monitor_geometry
calculate_position

# Command-line argument handling
if [ -n "$1" ]; then
    if [ -d "$1" ]; then
        launch_random_media "$1"
    else
        FILE="$1"
        EXT="${FILE##*.}"
        case "$EXT" in
            mp4|mkv|webm|gif) launch_video "single" "$FILE" ;;
            jpg|jpeg|png|bmp) launch_image "$FILE" ;;
            *) echo "❌ Unsupported file type: $FILE" ;;
        esac
    fi
    exit 0
fi

# Launch a single random wallpaper from custom folder
if [ -n "$CUSTOM_FOLDER" ] && [ -d "$CUSTOM_FOLDER" ]; then
    echo "🎯 Launching a random wallpaper from custom folder: $CUSTOM_FOLDER"
    FILES=("$CUSTOM_FOLDER"/*)
    if [ ${#FILES[@]} -gt 0 ]; then
        RANDOM_FILE="${FILES[RANDOM % ${#FILES[@]}]}"
        EXT="${RANDOM_FILE##*.}"
        case "$EXT" in
            mp4|mkv|webm|gif) launch_video "single" "$RANDOM_FILE" ;;
            jpg|jpeg|png|bmp) launch_image "$RANDOM_FILE" ;;
            *) echo "❌ Unsupported file type: $RANDOM_FILE" ;;
        esac
    else
        echo "❌ No files found in $CUSTOM_FOLDER"
    fi
fi

# Load workspace wallpapers
for ws in "${!WALLPAPERS[@]}"; do
    FILE="${WALLPAPERS[$ws]}"
    [ -z "$FILE" ] && continue
    EXT="${FILE##*.}"
    case "$EXT" in
        mp4|mkv|webm|gif) launch_video "$ws" "$FILE" ;;
        jpg|jpeg|png|bmp) launch_image "$FILE" ;;
        *) echo "❌ Unsupported file type: $FILE" ;;
    esac
done

