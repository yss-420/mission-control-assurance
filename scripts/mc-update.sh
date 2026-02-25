#!/bin/bash
# Mission Control Update Script
# Usage: ./mc-update.sh [command] [args]

set -e

MC_DIR="/data/workspace/mission-control"
DATA_DIR="$MC_DIR/data"
TASKS_FILE="$DATA_DIR/tasks.json"

cd "$MC_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help
show_help() {
    echo "Mission Control CLI"
    echo ""
    echo "Commands:"
    echo "  status                 Show current task status"
    echo "  start <task_id>        Start working on a task"
    echo "  status <id> <col>      Move task to column (backlog|in_progress|review|done)"
    echo "  comment <id> <text>    Add comment to task"
    echo "  subtask <id> <sub>     Mark subtask as done"
    echo "  complete <id>          Complete task and move to review"
    echo "  push <message>         Push changes to GitHub"
    echo ""
}

# Get task by ID
get_task() {
    local task_id=$1
    jq -r --arg id "$task_id" '.tasks[] | select(.id == $id)' "$TASKS_FILE"
}

# Update task status
update_status() {
    local task_id=$1
    local new_status=$2
    local tmp_file=$(mktemp)
    
    jq --arg id "$task_id" --arg status "$new_status" '
        .tasks |= map(if .id == $id then .status = $status else . end)
    ' "$TASKS_FILE" > "$tmp_file"
    
    mv "$tmp_file" "$TASKS_FILE"
    echo -e "${GREEN}✓ Task $task_id moved to $new_status${NC}"
}

# Add comment
add_comment() {
    local task_id=$1
    shift
    local comment="$*"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local tmp_file=$(mktemp)
    
    jq --arg id "$task_id" --arg text "$comment" --arg time "$timestamp" '
        .tasks |= map(if .id == $id then .comments += [{"timestamp": $time, "text": $text}] else . end)
    ' "$TASKS_FILE" > "$tmp_file"
    
    mv "$tmp_file" "$TASKS_FILE"
    echo -e "${GREEN}✓ Comment added to $task_id${NC}"
}

# Mark subtask done
mark_subtask() {
    local task_id=$1
    local subtask_id=$2
    local tmp_file=$(mktemp)
    
    jq --arg id "$task_id" --arg subid "$subtask_id" '
        .tasks |= map(if .id == $id then .subtasks |= map(if .id == $subid then .done = true else . end) else . end)
    ' "$TASKS_FILE" > "$tmp_file"
    
    mv "$tmp_file" "$TASKS_FILE"
    echo -e "${GREEN}✓ Subtask $subtask_id marked done${NC}"
}

# Main command handler
case "$1" in
    status)
        if [ -z "$2" ]; then
            echo "Current Tasks:"
            echo ""
            jq -r '.tasks[] | "\(.id) | [\(.status)] | \(.title)"' "$TASKS_FILE" | column -t -s'|'
        fi
        ;;
    start)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Task ID required${NC}"
            exit 1
        fi
        update_status "$2" "in_progress"
        add_comment "$2" "🤖 Agent started working on this task"
        ;;
    comment)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Task ID and comment required${NC}"
            exit 1
        fi
        task_id="$2"
        shift 2
        add_comment "$task_id" "$*"
        ;;
    subtask)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo -e "${RED}Error: Task ID and subtask ID required${NC}"
            exit 1
        fi
        mark_subtask "$2" "$3"
        ;;
    complete)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Task ID required${NC}"
            exit 1
        fi
        update_status "$2" "review"
        ;;
    push)
        message="${2:-Update tasks}"
        git add -A
        git commit -m "$message" || true
        git push origin main
        echo -e "${GREEN}✓ Changes pushed to GitHub${NC}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
