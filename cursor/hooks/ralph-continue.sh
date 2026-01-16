#!/bin/bash
# Ralph Continue Hook for Cursor
# Automatically continues to next story when current completes
#
# Input (JSON from stdin):
#   { "status": "completed"|"aborted"|"error", "loop_count": 0 }
#
# Output (JSON to stdout):
#   { "followup_message": "..." } to auto-submit next message
#
# Exit codes:
#   0 = success (with or without followup)

# Read input
INPUT=$(cat)
STATUS=$(echo "$INPUT" | jq -r '.status // "unknown"')
LOOP_COUNT=$(echo "$INPUT" | jq -r '.loop_count // 0')

# Safety: Stop after 5 auto-followups (Cursor enforces this anyway)
if [ "$LOOP_COUNT" -ge 5 ]; then
  echo '{"followup_message": ""}'
  exit 0
fi

# Only continue on successful completion
if [ "$STATUS" != "completed" ]; then
  echo '{"followup_message": ""}'
  exit 0
fi

# Check if Ralph is active (prd.json exists)
if [ ! -f ".ralph/prd.json" ]; then
  echo '{"followup_message": ""}'
  exit 0
fi

# Count remaining stories
REMAINING=$(jq '[.userStories[] | select(.passes == false)] | length' .ralph/prd.json 2>/dev/null || echo "0")

if [ "$REMAINING" -gt 0 ]; then
  # Get next story
  NEXT_STORY=$(jq -r '.userStories[] | select(.passes == false) | "\(.id): \(.title)"' .ralph/prd.json | head -1)
  
  # Output followup message to continue
  cat << EOF
{"followup_message": "Continue Ralph: $REMAINING stories remaining. Implement the next story: $NEXT_STORY. Read .ralph/prompt.md for instructions."}
EOF
else
  # All done
  echo '{"followup_message": ""}'
fi

exit 0
