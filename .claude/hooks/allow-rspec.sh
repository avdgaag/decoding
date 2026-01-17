#!/bin/bash
# Auto-allow RSpec commands

# Read JSON from stdin
input=$(cat)

# Extract command from JSON (handle mcp__acp__Bash tool)
command=$(echo "$input" | grep -o '"command":"[^"]*"' | head -1 | cut -d'"' -f4)

# Check if it's an RSpec command
if [[ "$command" =~ (^|[[:space:]])bundle[[:space:]]+exec[[:space:]]+rspec || "$command" =~ (^|[[:space:]])rspec ]]; then
  # Auto-allow RSpec commands
  echo '{"permissionDecision":"allow","permissionDecisionReason":"RSpec commands are safe in this repo"}' >&2
  exit 0
fi

# For other commands, no special handling
exit 0
