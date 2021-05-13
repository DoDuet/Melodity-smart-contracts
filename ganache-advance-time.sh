#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: ganache-advance-time.sh <seconds>"
    exit 1
fi

curl -H "Content-Type: application/json" -X POST \
    --data "{\"id\":1337,\"jsonrpc\":\"2.0\",\"method\":\"evm_increaseTime\",\"params\":[$1]}" \
    http://localhost:8545 1>/dev/null 2>&1
curl -H "Content-Type: application/json" -X POST \
    --data "{\"id\":1337,\"jsonrpc\":\"2.0\",\"method\":\"evm_mine\"}" \
    http://localhost:8545 1>/dev/null 2>&1
echo "Fast forwarding of $1 seconds"