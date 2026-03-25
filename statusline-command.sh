#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -z "$cwd" ]; then
  cwd=$(pwd)
fi

model=$(echo "$input" | jq -r '.model.display_name // .model // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tokens_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
tokens_output=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')
tokens_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Git repo name, branch und dirty-status
repo=""
branch=""
dirty=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)")
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if ! git -C "$cwd" diff --quiet 2>/dev/null || \
     ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
    dirty=" ✱"
  fi
fi

location="${repo:-$(basename "$cwd")}"

# Token-Zahlen formatieren (z.B. 12400 -> 12.4k)
format_tokens() {
  local n=$1
  if [ -z "$n" ] || [ "$n" = "null" ]; then
    echo "-"
    return
  fi
  if [ "$n" -ge 1000 ]; then
    printf "%.1fk" "$(echo "scale=1; $n / 1000" | bc)"
  else
    echo "$n"
  fi
}

# Zeile 1
branch_fmt=""
if [ -n "$branch" ]; then
  branch_fmt=$(printf "\033[01;33m%s\033[00m" "$branch")
fi
dirty_fmt=""
if [ -n "$dirty" ]; then
  dirty_fmt=$(printf "\033[01;31m%s\033[00m" "$dirty")
fi
line1=$(printf "\033[01;37m[%s]\033[00m  \xF0\x9F\x93\x81 %s  %s%s" "$model" "$location" "$branch_fmt" "$dirty_fmt")

# Zeile 2 – Context Bar + Token-Zahlen
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  bar_length=10
  filled=$(( used_int * bar_length / 100 ))
  empty=$(( bar_length - filled ))

  if [ "$used_int" -ge 90 ]; then
    color="\033[01;31m"
  elif [ "$used_int" -ge 50 ]; then
    color="\033[01;33m"
  else
    color="\033[01;32m"
  fi
  reset="\033[00m"

  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty); do bar="${bar}░"; done

  t_input=$(format_tokens "$tokens_input")
  t_output=$(format_tokens "$tokens_output")
  t_total=$(format_tokens "$tokens_total")

  line2=$(printf "Context ${color}[%s] %d%%${reset}  in:%s out:%s / %s" "$bar" "$used_int" "$t_input" "$t_output" "$t_total")
else
  line2=$(printf "Context \033[01;32m[░░░░░░░░░░] -\033[00m  - / - tokens")
fi

printf "%s\n%s" "$line1" "$line2"
