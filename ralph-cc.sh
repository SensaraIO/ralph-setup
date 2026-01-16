#!/bin/bash
# Ralph-CC - Autonomous AI agent loop for Claude Code
# Fresh context per story with live output streaming
# Usage: ./ralph-cc.sh [max_iterations]

set -e

MAX_ITERATIONS=${1:-50}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$SCRIPT_DIR/.ralph"
PRD_FILE="$RALPH_DIR/prd.json"
PROGRESS_FILE="$RALPH_DIR/progress.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_story() { echo -e "${CYAN}[STORY]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
  if ! command -v claude &> /dev/null; then
    log_error "Claude Code CLI not found"
    log_info "Install from: https://docs.anthropic.com/claude-code"
    exit 1
  fi
  
  if ! command -v jq &> /dev/null; then
    log_error "jq not found. Install: brew install jq"
    exit 1
  fi
  
  if [ ! -f "$PRD_FILE" ]; then
    log_error "prd.json not found at $PRD_FILE"
    log_info "Generate it with: claude then 'Load brs-to-ralph skill, convert docs/your-brs.md'"
    exit 1
  fi
}

# Get remaining story count
get_remaining() {
  jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE"
}

# Get total story count
get_total() {
  jq '.userStories | length' "$PRD_FILE"
}

# Get next story info
get_next_story() {
  jq -r '.userStories[] | select(.passes == false) | "\(.id): \(.title)"' "$PRD_FILE" | head -1
}

# Get next story ID only
get_next_story_id() {
  jq -r '.userStories[] | select(.passes == false) | .id' "$PRD_FILE" | head -1
}

# Get current phase
get_current_phase() {
  local story_id=$(get_next_story_id)
  jq -r --arg id "$story_id" '.userStories[] | select(.id == $id) | .phaseId' "$PRD_FILE"
}

# Build the prompt for Claude
build_prompt() {
  local story_id=$1
  cat << EOF
You are an autonomous coding agent. Read .ralph/prompt.md for full instructions.

YOUR TASK NOW: Implement story $story_id from .ralph/prd.json

Steps:
1. Read .ralph/prd.json to get the story details for $story_id
2. Read .ralph/progress.txt for codebase patterns (IMPORTANT - check Codebase Patterns section first)
3. Read .ralph/testid-contracts.json if the story has UI elements - you MUST include all required testIDs
4. Implement the story following acceptance criteria exactly
5. Run quality checks: npx tsc --noEmit && npx expo lint
6. If checks pass, stage files with: git add [files]
7. Update .ralph/prd.json to set passes: true for $story_id
8. Append your progress to .ralph/progress.txt with learnings

IMPORTANT:
- Do NOT commit, only stage files
- Do NOT ask questions - make reasonable decisions and proceed
- Include ALL testIDs from testid-contracts.json for this story

If ALL stories are now complete, end your response with: <promise>COMPLETE</promise>
Otherwise just finish normally after updating the files.

Start implementing $story_id now.
EOF
}

# Run one iteration
run_iteration() {
  local iteration=$1
  local story_id=$2
  
  log_info "Spawning Claude Code for $story_id..."
  echo ""
  
  # Build prompt
  local prompt=$(build_prompt "$story_id")
  
  # Run Claude with print mode - output streams directly to terminal
  # Using script for unbuffered output on macOS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use script for unbuffered output
    script -q /dev/null claude -p --dangerously-skip-permissions "$prompt" 2>&1
  else
    # Linux - try unbuffer or stdbuf
    if command -v unbuffer &> /dev/null; then
      unbuffer claude -p --dangerously-skip-permissions "$prompt" 2>&1
    elif command -v stdbuf &> /dev/null; then
      stdbuf -oL claude -p --dangerously-skip-permissions "$prompt" 2>&1
    else
      claude -p --dangerously-skip-permissions "$prompt" 2>&1
    fi
  fi
  
  return $?
}

# Main
main() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║                      RALPH-CC                                ║"
  echo "║       Fresh Context Per Story • Live Output                  ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  
  check_prerequisites
  
  local project=$(jq -r '.project // "Unknown"' "$PRD_FILE")
  local branch=$(jq -r '.branchName // "main"' "$PRD_FILE")
  local total=$(get_total)
  local remaining=$(get_remaining)
  local completed=$((total - remaining))
  
  log_info "Project: $project"
  log_info "Branch: $branch"
  log_info "Progress: $completed/$total stories complete"
  log_info "Max iterations: $MAX_ITERATIONS"
  echo ""
  
  # Ensure we're on the right branch
  local current_branch=$(git branch --show-current 2>/dev/null || echo "")
  if [ -n "$branch" ] && [ "$current_branch" != "$branch" ]; then
    log_info "Switching to branch: $branch"
    git checkout "$branch" 2>/dev/null || git checkout -b "$branch" 2>/dev/null || true
  fi
  
  for i in $(seq 1 $MAX_ITERATIONS); do
    remaining=$(get_remaining)
    
    if [ "$remaining" -eq 0 ]; then
      echo ""
      log_success "════════════════════════════════════════════════════════════"
      log_success "  ALL STORIES COMPLETE! ($total/$total)"
      log_success "════════════════════════════════════════════════════════════"
      echo ""
      log_info "Review staged changes: git status"
      log_info "Commit when ready: git commit -m 'feat: Complete $project'"
      exit 0
    fi
    
    local next_story=$(get_next_story)
    local story_id=$(get_next_story_id)
    local phase=$(get_current_phase)
    completed=$((total - remaining))
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  ${CYAN}Iteration $i of $MAX_ITERATIONS${NC}"
    echo -e "  ${GREEN}Progress: $completed/$total${NC} │ ${YELLOW}Remaining: $remaining${NC}"
    echo -e "  ${BLUE}Phase: $phase${NC}"
    log_story "$next_story"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Run the iteration
    run_iteration "$i" "$story_id"
    
    # Check if story was completed
    local story_status=$(jq -r --arg id "$story_id" '.userStories[] | select(.id == $id) | .passes' "$PRD_FILE")
    
    if [ "$story_status" = "true" ]; then
      echo ""
      log_success "Story $story_id completed!"
    else
      echo ""
      log_warning "Story $story_id may not have completed fully. Continuing..."
    fi
    
    # Small delay between iterations
    sleep 2
  done
  
  echo ""
  log_warning "Reached max iterations ($MAX_ITERATIONS)"
  remaining=$(get_remaining)
  completed=$((total - remaining))
  log_info "Progress: $completed/$total complete, $remaining remaining"
  log_info "Run again to continue: ./ralph-cc.sh"
  exit 1
}

main
