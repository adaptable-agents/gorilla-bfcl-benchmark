import os

from bfcl_eval.model_handler.api_inference.glm import GLMAPIHandler
from bfcl_eval.constants.enums import ModelStyle
from openai import OpenAI
import httpx

try:
    from adaptable_agents import AdaptableOpenAIClient, ContextConfig
except ImportError as e:
    raise ImportError(
        f"adaptable_agents package not found: {e}. Please install it in your virtual environment."
    )


class GLMAdaptableHandler(GLMAPIHandler):
    """
    GLM API Handler with Adaptable Agents integration.

    This handler wraps the GLM OpenAI-compatible API with Adaptable Agents
    to automatically fetch and append context, and store memories.
    """

    def __init__(
        self,
        model_name,
        temperature,
        registry_name,
        is_fc_model,
        **kwargs,
    ) -> None:
        # Initialize parent without calling super().__init__ to avoid creating the client twice
        from bfcl_eval.model_handler.base_handler import BaseHandler

        BaseHandler.__init__(
            self, model_name, temperature, registry_name, is_fc_model, **kwargs
        )

        # Set model_style for tool compilation (inherited from OpenAICompletionsHandler)
        self.model_style = ModelStyle.OPENAI_COMPLETIONS

        # Create the base GLM OpenAI client
        glm_client = OpenAI(
            api_key=os.getenv("GLM_API_KEY"),
            base_url="https://api.z.ai/api/paas/v4/",
            timeout=httpx.Timeout(timeout=300.0, connect=8.0),
        )

        # Get adaptable agents configuration from environment variables
        adaptable_api_key = os.getenv("ADAPTABLE_API_KEY")
        if not adaptable_api_key:
            raise ValueError(
                "ADAPTABLE_API_KEY environment variable is required for GLMAdaptableHandler. "
                "Please set it in your .env file or as an environment variable."
            )

        adaptable_api_base_url = os.getenv(
            "ADAPTABLE_API_BASE_URL", "http://localhost:8000"
        )
        memory_scope_path = os.getenv("ADAPTABLE_MEMORY_SCOPE_PATH", "bfcl/glm")

        # Get context config from environment variables (optional)
        similarity_threshold = float(os.getenv("ADAPTABLE_SIMILARITY_THRESHOLD", "0.5"))
        max_items = int(os.getenv("ADAPTABLE_MAX_ITEMS", "20"))

        context_config = ContextConfig(
            similarity_threshold=similarity_threshold,
            max_items=max_items,
        )

        # Wrap the GLM client with AdaptableOpenAIClient
        self.client = AdaptableOpenAIClient(
            adaptable_api_key=adaptable_api_key,
            api_base_url=adaptable_api_base_url,
            openai_client=glm_client,
            memory_scope_path=memory_scope_path,
            context_config=context_config,
            auto_store_memories=os.getenv(
                "ADAPTABLE_AUTO_STORE_MEMORIES", "true"
            ).lower()
            == "true",
            enable_adaptable_agents=True,
        )
