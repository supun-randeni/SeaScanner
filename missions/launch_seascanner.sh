#!/bin/bash

# Launch the single VAL community used by the Omniscan bootcamp.

GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MISSION_FILE="$SCRIPT_DIR/seascanner.moos"
TIME_WARP=1

for ARGI; do
    if [[ "$ARGI" == "--help" || "$ARGI" == "-h" ]]; then
        echo "Usage: ./launch_seascanner.sh [time_warp]"
        exit 0
    elif [[ "$ARGI" =~ ^[0-9]+$ && "$TIME_WARP" == 1 ]]; then
        TIME_WARP="$ARGI"
    else
        echo "${RED}Bad argument: $ARGI${NC}" >&2
        exit 1
    fi
done

export PATH="$PROJECT_DIR/src/python/iOmniscan_bootcamp:$PROJECT_DIR/bin:$PATH"

mkdir -p "$PROJECT_DIR/logs"
cd "$PROJECT_DIR" || exit 1

echo "${GREEN}Launching VAL MOOS community. WARP is $TIME_WARP${NC}"
pAntler "$MISSION_FILE" --MOOSTimeWarp="$TIME_WARP" >& /dev/null &
ANTLER_PID=$!

# Stop the launched community when uMAC exits.
trap 'kill "$ANTLER_PID" 2>/dev/null; wait "$ANTLER_PID" 2>/dev/null' EXIT INT TERM

echo "Done"
uMAC -t "$MISSION_FILE"
