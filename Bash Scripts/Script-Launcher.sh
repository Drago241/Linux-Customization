#!/bin/bash

# ==========================
# Run Multiple Scripts at Once
# ==========================

# Add your script paths here
SCRIPT1=""   # e.g., /home/user/scripts/myscript1.sh
SCRIPT2=""   # e.g., /home/user/scripts/myscript2.sh
SCRIPT3=""   # e.g., /home/user/scripts/myscript3.sh

# Add more scripts as needed
SCRIPTS=("$SCRIPT1" "$SCRIPT2" "$SCRIPT3")

# Function to run each script
run_script() {
    local script_path="$1"
    if [[ -z "$script_path" ]]; then
        echo "Skipping empty script path."
    elif [[ ! -x "$script_path" ]]; then
        echo "Script '$script_path' is not executable or does not exist. Skipping."
    else
        echo "Running '$script_path'..."
        "$script_path"
        echo "'$script_path' finished."
    fi
}

# Run all scripts in order
for script in "${SCRIPTS[@]}"; do
    run_script "$script"
done

echo "All scripts executed."

