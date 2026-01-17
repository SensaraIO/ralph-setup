#!/bin/bash
# Ralph Continue Hook for Cursor
# Auto-continues to next story when current completes

INPUT=$(cat)
STATUS=$(echo "$INPUT" | jq -r '.status // "unknown"')
LOOP_COUNT=$(echo "$INPUT" | jq -r '.loop_count // 0')

# Safety: Max 5 auto-followups
if [ "$LOOP_COUNT" -ge 5 ]; then
  echo '{"followup_message": ""}'
  exit 0
fi

# Only continue on success
if [ "$STATUS" != "completed" ]; then
  echo '{"followup_message": ""}'
  exit 0
fi

# Check if Ralph active
if [ ! -f ".ralph/prd.json" ]; then
  echo '{"followup_message": ""}'
  exit 0
fi

REMAINING=$(jq '[.userStories[] | select(.passes == false)] | length' .ralph/prd.json 2>/dev/null || echo "0")

if [ "$REMAINING" -gt 0 ]; then
  NEXT_STORY=$(jq -r '.userStories[] | select(.passes == false) | "\(.id): \(.title)"' .ralph/prd.json | head -1)
  LAYER=$(jq -r '.userStories[] | select(.passes == false) | .layer // "fullstack"' .ralph/prd.json | head -1)
  
  cat << EOF
{"followup_message": "Continue Ralph: $REMAINING stories remaining. Next: $NEXT_STORY (layer: $LAYER). Read .ralph/prompt.md for instructions."}
EOF
else
  echo '{"followup_message": ""}'
fi

exit 0
