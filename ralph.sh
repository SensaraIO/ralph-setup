#!/bin/bash
# Ralph - Autonomous AI agent loop
# Works with: Claude Code, Cursor, Codex, Aider, Amp
# Usage: ./ralph.sh [--agent <name>] [--max <iterations>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$SCRIPT_DIR/.ralph"
PRD_FILE="$RALPH_DIR/prd.json"
PROGRESS_FILE="$RALPH_DIR/progress.txt"
CONFIG_FILE="$RALPH_DIR/config.json"

# Defaults
DEFAULT_AGENT="claude"
DEFAULT_MAX=50

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

# Parse arguments
AGENT_OVERRIDE=""
MAX_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --agent)
      AGENT_OVERRIDE="$2"
      shift 2
      ;;
    --max)
      MAX_OVERRIDE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Load config
load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    AGENT=$(jq -r '.agent // "claude"' "$CONFIG_FILE")
    MAX_ITERATIONS=$(jq -r '.maxIterations // 50' "$CONFIG_FILE")
    MODEL=$(jq -r '.model // null' "$CONFIG_FILE")
  else
    AGENT="$DEFAULT_AGENT"
    MAX_ITERATIONS=$DEFAULT_MAX
    MODEL=""
  fi
  
  # Apply overrides
  [ -n "$AGENT_OVERRIDE" ] && AGENT="$AGENT_OVERRIDE"
  [ -n "$MAX_OVERRIDE" ] && MAX_ITERATIONS="$MAX_OVERRIDE"
}

# Check prerequisites
check_prerequisites() {
  if ! command -v jq &> /dev/null; then
    log_error "jq not found. Install: brew install jq"
    exit 1
  fi
  
  if [ ! -f "$PRD_FILE" ]; then
    log_error "prd.json not found at $PRD_FILE"
    log_info "Generate it by converting your BRS document"
    exit 1
  fi
  
  # Check agent CLI
  case "$AGENT" in
    claude)
      if ! command -v claude &> /dev/null; then
        log_error "Claude Code CLI not found"
        exit 1
      fi
      ;;
    cursor)
      if ! command -v cursor &> /dev/null && ! command -v agent &> /dev/null; then
        log_error "Cursor CLI not found"
        exit 1
      fi
      ;;
    codex)
      if ! command -v codex &> /dev/null; then
        log_error "Codex CLI not found"
        exit 1
      fi
      ;;
    aider)
      if ! command -v aider &> /dev/null; then
        log_error "Aider not found"
        exit 1
      fi
      ;;
    amp)
      if ! command -v amp &> /dev/null; then
        log_error "Amp not found"
        exit 1
      fi
      ;;
    *)
      log_error "Unknown agent: $AGENT"
      log_info "Supported: claude, cursor, codex, aider, amp"
      exit 1
      ;;
  esac
  
  log_success "Agent: $AGENT"
}

# Get story info
get_remaining() {
  jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE"
}

get_total() {
  jq '.userStories | length' "$PRD_FILE"
}

get_next_story() {
  jq -r '.userStories[] | select(.passes == false) | "\(.id): \(.title)"' "$PRD_FILE" | head -1
}

get_next_story_id() {
  jq -r '.userStories[] | select(.passes == false) | .id' "$PRD_FILE" | head -1
}

get_current_phase() {
  local story_id=$(get_next_story_id)
  jq -r --arg id "$story_id" '.userStories[] | select(.id == $id) | .phaseId' "$PRD_FILE"
}

# Build prompt
build_prompt() {
  local story_id=$1
  cat << EOF
You are an autonomous coding agent. Read .ralph/prompt.md for full instructions.

YOUR TASK: Implement story $story_id from .ralph/prd.json

Steps:
1. Read .ralph/prd.json to get story details for $story_id
2. Read .ralph/progress.txt - check Codebase Patterns section FIRST
3. Read .ralph/testid-contracts.json if story has UI elements - include ALL required testIDs
4. Implement the story following acceptance criteria exactly
5. Run quality checks: npx tsc --noEmit && npx expo lint
6. If checks pass, stage files: git add [files]
7. Update .ralph/prd.json to set passes: true for $story_id
8. Append progress to .ralph/progress.txt with learnings

IMPORTANT:
- Do NOT commit, only stage files
- Do NOT ask questions - make reasonable decisions
- Include ALL testIDs from contracts

If ALL stories complete, end with: <promise>COMPLETE</promise>

Start implementing $story_id now.
EOF
}

# Run agent
run_agent() {
  local prompt="$1"
  
  case "$AGENT" in
    claude)
      if [[ "$OSTYPE" == "darwin"* ]]; then
        script -q /dev/null claude -p --dangerously-skip-permissions "$prompt" 2>&1
      else
        claude -p --dangerously-skip-permissions "$prompt" 2>&1
      fi
      ;;
    cursor)
      # Cursor CLI uses 'agent' command or 'cursor'
      if command -v agent &> /dev/null; then
        agent -p "$prompt" 2>&1
      else
        cursor -p "$prompt" 2>&1
      fi
      ;;
    codex)
      codex --approval-mode full-auto "$prompt" 2>&1
      ;;
    aider)
      echo "$prompt" | aider --yes-always --no-git 2>&1
      ;;
    amp)
      echo "$prompt" | amp --dangerously-allow-all 2>&1
      ;;
  esac
}

# Main loop
main() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║                         RALPH                                ║"
  echo "║          Autonomous AI Agent Loop                            ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  
  load_config
  check_prerequisites
  
  local project=$(jq -r '.project // "Unknown"' "$PRD_FILE")
  local branch=$(jq -r '.branchName // "main"' "$PRD_FILE")
  local total=$(get_total)
  local remaining=$(get_remaining)
  local completed=$((total - remaining))
  
  log_info "Project: $project"
  log_info "Branch: $branch"
  log_info "Progress: $completed/$total stories"
  log_info "Max iterations: $MAX_ITERATIONS"
  echo ""
  
  # Switch to branch if needed
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
      log_info "Review: git status"
      log_info "Commit: git commit -m 'feat: Complete $project'"
      exit 0
    fi
    
    local next_story=$(get_next_story)
    local story_id=$(get_next_story_id)
    local phase=$(get_current_phase)
    completed=$((total - remaining))
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  ${CYAN}Iteration $i of $MAX_ITERATIONS${NC} │ ${BLUE}Agent: $AGENT${NC}"
    echo -e "  ${GREEN}Progress: $completed/$total${NC} │ ${YELLOW}Remaining: $remaining${NC}"
    echo -e "  ${BLUE}Phase: $phase${NC}"
    log_story "$next_story"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    local prompt=$(build_prompt "$story_id")
    run_agent "$prompt"
    
    # Check completion
    local status=$(jq -r --arg id "$story_id" '.userStories[] | select(.id == $id) | .passes' "$PRD_FILE")
    
    if [ "$status" = "true" ]; then
      echo ""
      log_success "Story $story_id completed!"
    else
      echo ""
      log_warning "Story $story_id may not have completed. Continuing..."
    fi
    
    sleep 2
  done
  
  echo ""
  log_warning "Reached max iterations ($MAX_ITERATIONS)"
  log_info "Run again to continue: ./ralph.sh"
  exit 1
}

main
