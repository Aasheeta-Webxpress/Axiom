import os
from pathlib import Path
from typing import Dict, Any

class Settings:
    # Project paths
    ROOT_DIR = Path(__file__).parent.parent.parent
    AXIOM_BACKEND_DIR = ROOT_DIR / "axiomBackend"
    AXIOM_FLUTTER_DIR = ROOT_DIR / "axiom"
    
    # Backend API configuration
    BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:5000")
    BACKEND_API_BASE = f"{BACKEND_URL}/api"
    
    # MongoDB configuration (from backend)
    MONGODB_URI = os.getenv("MONGODB_URI", "mongodb+srv://aasheeta:rtyfgho;@users.mdpvhwc.mongodb.net/")
    
    # Agent configuration
    AGENT_PORT = int(os.getenv("AGENT_PORT", 8000))
    AGENT_HOST = os.getenv("AGENT_HOST", "localhost")
    
    # Memory configuration
    QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
    QDRANT_COLLECTION_NAME = "axiom_codebase"
    
    # LLM configuration
    LLM_MODEL = os.getenv("LLM_MODEL", "deepseek-coder")
    LLM_API_KEY = os.getenv("LLM_API_KEY", "")
    LLM_BASE_URL = os.getenv("LLM_BASE_URL", "")
    
    # File processing
    SUPPORTED_CODE_EXTENSIONS = {
        ".py", ".js", ".ts", ".dart", ".jsx", ".tsx",
        ".java", ".cpp", ".c", ".h", ".cs", ".go", ".rs"
    }
    
    IGNORED_PATTERNS = {
        ".git", "node_modules", ".dart_tool", "build", 
        "dist", "__pycache__", ".vscode", ".idea"
    }
    
    @classmethod
    def get_project_paths(cls) -> Dict[str, Path]:
        return {
            "backend": cls.AXIOM_BACKEND_DIR,
            "flutter": cls.AXIOM_FLUTTER_DIR,
            "root": cls.ROOT_DIR
        }
    
    @classmethod
    def validate_paths(cls) -> bool:
        required_paths = [cls.AXIOM_BACKEND_DIR, cls.AXIOM_FLUTTER_DIR]
        return all(path.exists() for path in required_paths)

settings = Settings()
