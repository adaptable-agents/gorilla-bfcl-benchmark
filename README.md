# GLM Adaptable Evaluation

This repository contains a Makefile to run the GLM Adaptable evaluation on the Berkeley Function Call Leaderboard.

## Usage

### Running the Evaluation

Run the evaluation with default settings:

```bash
make eval
```

Or run with custom configuration:

```bash
make eval MODEL_NAME=glm-4.5-adaptable-FC TEST_CATEGORY=all NUM_THREADS=4
```

### View Help

To see all available options:

```bash
make help
```

## Configuration Variables

The following variables can be overridden when running `make eval`:

- **MODEL_NAME**: Model name (default: `glm-4.5-adaptable-FC`)
- **TEST_CATEGORY**: Test category (default: `simple_python`)
- **NUM_THREADS**: Number of threads (default: `1`)
- **BFCL_PROJECT_ROOT**: Project root directory (default: current directory)

## Examples

```bash
# Run with default settings
make eval

# Run with different model and test category
make eval MODEL_NAME=glm-4.5-adaptable-FC TEST_CATEGORY=all

# Run with multiple threads
make eval NUM_THREADS=4

# Run with all custom settings
make eval MODEL_NAME=glm-4.5-adaptable-FC TEST_CATEGORY=all NUM_THREADS=4
```

## Requirements

Before running the evaluation, ensure you have:

1. Required environment variables set (either in your environment or in a `.env` file):
   - `GLM_API_KEY`: Your GLM API key
   - `ADAPTABLE_API_KEY`: Your Adaptable API key

2. Optional environment variables:
   - `ADAPTABLE_API_BASE_URL`: Adaptable API base URL (default: `http://localhost:8000`)
   - `ADAPTABLE_MEMORY_SCOPE_PATH`: Memory scope path (default: `bfcl/glm`)
   - `ADAPTABLE_SIMILARITY_THRESHOLD`: Similarity threshold (default: `0.5`)
   - `ADAPTABLE_MAX_ITEMS`: Maximum items (default: `20`)
   - `ADAPTABLE_AUTO_STORE_MEMORIES`: Auto store memories (default: `true`)

3. The evaluation script located at: `berkeley-function-call-leaderboard/run_glm_adaptable_eval.sh`

## Results

After running the evaluation, results will be stored in:

- **Predictions**: `result/{MODEL_NAME}/`
- **Scores**: `score/{MODEL_NAME}/`

CSV summary files are available in the `score/` directory:
- `data_overall.csv`
- `data_live.csv`
- `data_non_live.csv`
- `data_multi_turn.csv`
