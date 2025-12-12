#!/bin/bash

# Script to generate predictions and evaluate using GLM LLM with Adaptable Agents
# This script runs the Berkeley Function Call Leaderboard evaluation with GLM models
# wrapped with Adaptable Agents for context-aware function calling.

set -e  # Exit on error

# Configuration
MODEL_NAME="${MODEL_NAME:-glm-4.5-adaptable-FC}"
# TEST_CATEGORY="${TEST_CATEGORY:-all}"
TEST_CATEGORY="simple_python"

NUM_THREADS="${NUM_THREADS:-1}"
BFCL_PROJECT_ROOT="${BFCL_PROJECT_ROOT:-$(pwd)}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}GLM with Adaptable Agents Evaluation${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Change to the berkeley-function-call-leaderboard directory first
cd "$(dirname "${BASH_SOURCE[0]}")"

# Load .env file if it exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}Loading environment variables from .env file...${NC}"
    # Export variables from .env file
    # This will automatically export all variables defined in .env
    set -a
    source .env
    set +a
    echo -e "${GREEN}✓ Loaded .env file${NC}"
    echo ""
fi

# Check required environment variables
echo -e "${YELLOW}Checking environment variables...${NC}"

REQUIRED_VARS=("GLM_API_KEY" "ADAPTABLE_API_KEY")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo -e "${RED}  - $var${NC}"
    done
    echo ""
    echo "Please set these variables in your environment or .env file:"
    echo "  export GLM_API_KEY='your-glm-api-key'"
    echo "  export ADAPTABLE_API_KEY='your-adaptable-api-key'"
    echo ""
    echo "Optional variables:"
    echo "  export ADAPTABLE_API_BASE_URL='http://localhost:8000'  # Default: http://localhost:8000"
    echo "  export ADAPTABLE_MEMORY_SCOPE_PATH='bfcl/glm'          # Default: bfcl/glm"
    echo "  export ADAPTABLE_SIMILARITY_THRESHOLD='0.5'            # Default: 0.5"
    echo "  export ADAPTABLE_MAX_ITEMS='20'                        # Default: 20"
    echo "  export ADAPTABLE_AUTO_STORE_MEMORIES='true'            # Default: true"
    exit 1
fi

echo -e "${GREEN}✓ All required environment variables are set${NC}"
echo ""

# Display configuration
echo -e "${GREEN}Configuration:${NC}"
echo "  Model: $MODEL_NAME"
echo "  Test Category: $TEST_CATEGORY"
echo "  Num Threads: $NUM_THREADS"
echo "  Project Root: $BFCL_PROJECT_ROOT"
echo "  Adaptable API Base URL: ${ADAPTABLE_API_BASE_URL:-http://localhost:8000}"
echo "  Memory Scope Path: ${ADAPTABLE_MEMORY_SCOPE_PATH:-bfcl/glm}"
echo ""

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ] && [ ! -f "bfcl_eval/__init__.py" ]; then
    echo -e "${RED}Error: This script must be run from the berkeley-function-call-leaderboard directory${NC}"
    exit 1
fi

# Activate conda environment if BFCL environment exists
if command -v conda &> /dev/null; then
    if conda env list | grep -q "^BFCL "; then
        echo -e "${YELLOW}Activating conda environment: BFCL${NC}"
        eval "$(conda shell.bash hook)"
        conda activate BFCL
    fi
fi

# Step 1: Generate predictions
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Step 1: Generating LLM Responses${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

uv run bfcl generate \
    --model "$MODEL_NAME" \
    --test-category "$TEST_CATEGORY" \
    --num-threads "$NUM_THREADS"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Generation failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Generation completed successfully${NC}"
echo ""

# Step 2: Evaluate generated responses
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Step 2: Evaluating Generated Responses${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

uv run bfcl evaluate \
    --model "$MODEL_NAME" \
    --test-category "$TEST_CATEGORY"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Evaluation failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Evaluation completed successfully${NC}"
echo ""

# Display results location
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Results${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Results are stored in:"
echo "  - Predictions: $BFCL_PROJECT_ROOT/result/$MODEL_NAME/"
echo "  - Scores: $BFCL_PROJECT_ROOT/score/$MODEL_NAME/"
echo ""
echo "CSV summary files are in: $BFCL_PROJECT_ROOT/score/"
echo "  - data_overall.csv"
echo "  - data_live.csv"
echo "  - data_non_live.csv"
echo "  - data_multi_turn.csv"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Evaluation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

