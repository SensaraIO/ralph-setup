#!/bin/bash
# Ralph Progress Hook for Cursor
# Logs file edits during Ralph development
#
# Input (JSON from stdin):
#   { "file_path": "...", "edits": [...] }

# Read input and discard (we just log for observability)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // "unknown"')

# Only log if Ralph is active
if [ -f ".ralph/prd.json" ]; then
  # Log to a file for debugging (optional)
  echo "[$(date +%H:%M:%S)] Edited: $FILE_PATH" >> .ralph/.edit-log 2>/dev/null || true
fi

# No output needed
exit 0
