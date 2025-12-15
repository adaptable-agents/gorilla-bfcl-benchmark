.PHONY: eval help

# Default target
.DEFAULT_GOAL := eval

# Configuration variables (can be overridden via command line)
MODEL_NAME ?= glm-4.5-adaptable-FC
TEST_CATEGORY ?= simple_python
NUM_THREADS ?= 1
BFCL_PROJECT_ROOT ?= $(shell pwd)

# Path to the evaluation script
EVAL_SCRIPT := berkeley-function-call-leaderboard/run_glm_adaptable_eval.sh

help: ## Show this help message
	@echo "Usage: make [target] [variable=value]"
	@echo ""
	@echo "Targets:"
	@echo "  eval          Run the GLM Adaptable evaluation (default)"
	@echo "  help          Show this help message"
	@echo ""
	@echo "Variables (can be overridden):"
	@echo "  MODEL_NAME        Model name (default: glm-4.5-adaptable-FC)"
	@echo "  TEST_CATEGORY     Test category (default: simple_python)"
	@echo "  NUM_THREADS       Number of threads (default: 1)"
	@echo "  BFCL_PROJECT_ROOT Project root directory (default: current directory)"
	@echo ""
	@echo "Examples:"
	@echo "  make eval"
	@echo "  make eval MODEL_NAME=glm-4.5-adaptable-FC TEST_CATEGORY=all"
	@echo "  make eval NUM_THREADS=4"

eval: ## Run the GLM Adaptable evaluation
	@echo "Running GLM Adaptable evaluation..."
	@echo "Configuration:"
	@echo "  MODEL_NAME: $(MODEL_NAME)"
	@echo "  TEST_CATEGORY: $(TEST_CATEGORY)"
	@echo "  NUM_THREADS: $(NUM_THREADS)"
	@echo "  BFCL_PROJECT_ROOT: $(BFCL_PROJECT_ROOT)"
	@echo ""
	@if [ ! -f "$(EVAL_SCRIPT)" ]; then \
		echo "Error: Evaluation script not found at $(EVAL_SCRIPT)"; \
		exit 1; \
	fi
	@chmod +x "$(EVAL_SCRIPT)"
	@MODEL_NAME="$(MODEL_NAME)" \
	 TEST_CATEGORY="$(TEST_CATEGORY)" \
	 NUM_THREADS="$(NUM_THREADS)" \
	 BFCL_PROJECT_ROOT="$(BFCL_PROJECT_ROOT)" \
	 bash "$(EVAL_SCRIPT)"
