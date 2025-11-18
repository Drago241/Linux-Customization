#!/bin/bash

entries=(rc-bars.glsl rc-radial.glsl rc-circle.glsl rc-graph.glsl rc-wave.glsl)

# Check if any of these instances are running
running=$(pgrep -f "glava --desktop --entry=")

if [ -n "$running" ]; then
    echo "Closing Glava instances..."
    for entry in "${entries[@]}"; do
        pkill -f "glava --desktop --entry=$entry"
    done
else
    echo "Starting Glava instances..."
    for entry in "${entries[@]}"; do
        glava --desktop --entry="$entry" &
    done
    disown
fi

