#!/bin/bash

# Ensure script path is absolute and independent of execution location
# This sets SCRIPT_DIR to the directory where this script is located
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
CURR_DIR="$(pwd -P)"

source "$SCRIPT_DIR/mini-moul/config.sh"

# Assignment name initialization
assignment=NULL
run_norm=false

# Handle command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|-norm|--norminette)
            run_norm=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Handle SIGINT (Ctrl+C) to clean up before exit
handle_sigint() {
  echo "${RED}Script aborted by user. Cleaning up..."
  rm -rf "$SCRIPT_DIR/mini-moul"
  echo "${GREEN}Cleaning process done.${DEFAULT}"
  exit 1
}

# Detect assignment name based on current directory name
detect_assignment() {
  assignment=$(basename "$(pwd)")
  [[ $assignment =~ ^C(0[0-9]|1[0-3])$ ]]
}

# Run norminette if available
run_norminette() {
  if command -v norminette &> /dev/null; then
    echo -e "${BLUE}Running norminette checks...${DEFAULT}"
    norminette -R CheckForbiddenSourceHeader -R CheckDefine "$CURR_DIR"
  else
    echo -e "${YELLOW}norminette not found, skipping norminette checks${DEFAULT}"
  fi
}

if detect_assignment; then
  if [ "$run_norm" = true ]; then
    run_norminette || exit 1
  fi
  cp -R "$SCRIPT_DIR/mini-moul" "$CURR_DIR/mini-moul"
  trap handle_sigint SIGINT
  "$CURR_DIR/mini-moul/test.sh" "$assignment"
  rm -rf "$CURR_DIR/mini-moul"
else
  echo -e "${RED}Current directory does not match expected pattern (C[00~13]).${DEFAULT}\n"
  echo -e "${RED}Please navigate to an appropriate directory to run tests.${DEFAULT}\n"
fi

exit 1
