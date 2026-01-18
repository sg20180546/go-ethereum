#!/bin/bash
# Ethereum Single Node Performance Benchmark Script
# Trace-based performance evaluation using mainnet data

set -e

# Configuration
NODE_PORT=8545
NODE_HTTP_ADDR="127.0.0.1"
TRACE_START_BLOCK=18000000
TRACE_END_BLOCK=18010000
WORKLOAD_DIR="./cmd/workload"
RESULTS_DIR="./benchmark_results"

# Step 1: Create results directory
echo "=== Step 1: Creating results directory ==="
mkdir -p ${RESULTS_DIR}

# Step 2: Start Ethereum node (archive mode for full trace support)
echo "=== Step 2: Starting Ethereum node in archive mode ==="
echo "Command: geth --rpc --rpcaddr ${NODE_HTTP_ADDR} --rpcport ${NODE_PORT} --syncmode full --cache=4096 --datadir /home/femu/tenant0/p1"
echo "Note: Run this in a separate terminal or as background process"
echo "Waiting for node to be ready..."
sleep 5

# Step 3: Verify node connectivity
echo "=== Step 3: Verifying node connectivity ==="
if ! curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  http://${NODE_HTTP_ADDR}:${NODE_PORT} > /dev/null 2>&1; then
  echo "ERROR: Cannot connect to node at http://${NODE_HTTP_ADDR}:${NODE_PORT}"
  echo "Please start the node first with:"
  echo "  geth --rpc --rpcaddr ${NODE_HTTP_ADDR} --rpcport ${NODE_PORT} --syncmode full --cache=4096 --datadir /home/femu/tenant0/p1"
  exit 1
fi
echo "✓ Node is accessible"

# Step 4: Generate trace test data from mainnet
echo "=== Step 4: Generating trace test data (blocks ${TRACE_START_BLOCK}-${TRACE_END_BLOCK}) ==="
cd ${WORKLOAD_DIR}
go run . tracegen \
  --trace-tests queries/trace_mainnet.json \
  --trace-start ${TRACE_START_BLOCK} \
  --trace-end ${TRACE_END_BLOCK} \
  http://${NODE_HTTP_ADDR}:${NODE_PORT}
cd ../..
echo "✓ Trace test data generated"

# Step 5: Run trace performance benchmark
echo "=== Step 5: Running trace performance benchmark ==="
cd ${WORKLOAD_DIR}
go run . test \
  --run Trace \
  --output ../../${RESULTS_DIR}/trace_results.json \
  http://${NODE_HTTP_ADDR}:${NODE_PORT} | tee ../../${RESULTS_DIR}/trace_bench.log
cd ../..
echo "✓ Trace benchmark completed"

# Step 6: (Optional) Generate and run history tests
echo "=== Step 6: Generating history test data ==="
cd ${WORKLOAD_DIR}
go run . historygen \
  --history-tests queries/history_mainnet.json \
  http://${NODE_HTTP_ADDR}:${NODE_PORT}
cd ../..
echo "✓ History test data generated"

# Step 7: (Optional) Run history performance benchmark
echo "=== Step 7: Running history performance benchmark ==="
cd ${WORKLOAD_DIR}
go run . test \
  --run History \
  --output ../../${RESULTS_DIR}/history_results.json \
  http://${NODE_HTTP_ADDR}:${NODE_PORT} | tee ../../${RESULTS_DIR}/history_bench.log
cd ../..
echo "✓ History benchmark completed"

# Step 8: Summary
echo ""
echo "=== Benchmark Complete ==="
echo "Results saved to: ${RESULTS_DIR}/"
echo "  - trace_results.json"
echo "  - trace_bench.log"
echo "  - history_results.json"
echo "  - history_bench.log"
echo ""
echo "To analyze results:"
echo "  cat ${RESULTS_DIR}/trace_bench.log"
echo "  cat ${RESULTS_DIR}/history_bench.log"
