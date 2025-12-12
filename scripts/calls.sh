#!/usr/bin/env bash
set -euo pipefail

PKG_ID="0x1ca4878af7a847ccca3cd9ae9793988fecae23229684392d184788d7a4f562ce"
MODULE="simple_vote"
ADMIN_CAP_ID="0xcbdfab21259b1072e21c70a832082091a7c0a4c7863500ed49af43b0862fb9c4"
GAS_BUDGET="100000000"

create_poll() {
  local question="$1"
  local option_a="$2"
  local option_b="$3"
  sui client call \
    --package "$PKG_ID" \
    --module "$MODULE" \
    --function create_poll \
    --args "$ADMIN_CAP_ID" "$question" "$option_a" "$option_b" \
    --gas-budget "$GAS_BUDGET"
}

delete_poll() {
  local poll_id="$1"
  sui client call \
    --package "$PKG_ID" \
    --module "$MODULE" \
    --function delete_poll \
    --args "$ADMIN_CAP_ID" "$poll_id" \
    --gas-budget "$GAS_BUDGET"
}

new_vote() {
  local poll_id="$1"
  local option="$2" # 1 for A, 2 for B
  sui client call \
    --package "$PKG_ID" \
    --module "$MODULE" \
    --function new_vote \
    --args "$poll_id" "$option" \
    --gas-budget "$GAS_BUDGET"
}

update_vote() {
  local poll_id="$1"
  local new_option="$2"
  sui client call \
    --package "$PKG_ID" \
    --module "$MODULE" \
    --function update_vote \
    --args "$poll_id" "$new_option" \
    --gas-budget "$GAS_BUDGET"
}

delete_vote() {
  local poll_id="$1"
  sui client call \
    --package "$PKG_ID" \
    --module "$MODULE" \
    --function delete_vote \
    --args "$poll_id" \
    --gas-budget "$GAS_BUDGET"
}

get_vote() {
  local poll_id="$1"
  local voter_address="$2"
  sui client call \
    --package "$PKG_ID" \
    --module "$MODULE" \
    --function get_vote \
    --args "$poll_id" "$voter_address" \
    --gas-budget "$GAS_BUDGET"
}

usage() {
  echo "Usage:"
  echo "  create_poll \"Question\" \"Option A\" \"Option B\""
  echo "  delete_poll <POLL_ID>"
  echo "  new_vote <POLL_ID> <OPTION>"
  echo "  update_vote <POLL_ID> <NEW_OPTION>"
  echo "  delete_vote <POLL_ID>"
  echo "  get_vote <POLL_ID> <VOTER_ADDRESS>"
}

if [[ "${1:-}" == "" ]]; then
  usage
  exit 1
fi

cmd="$1"; shift
case "$cmd" in
  create_poll) create_poll "$@";;
  delete_poll) delete_poll "$@";;
  new_vote) new_vote "$@";;
  update_vote) update_vote "$@";;
  delete_vote) delete_vote "$@";;
  get_vote) get_vote "$@";;
  *) usage; exit 1;;
esac

