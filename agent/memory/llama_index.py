import os
from pathlib import Path
from typing import List, Dict, Any
from llama_index.core import SimpleDirectoryReader, VectorStoreIndex, Document
from llama_index.core.node_parser import SentenceSplitter
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.llms.ollama import Ollama

class LlamaIndexMemory:
    """Memory system using LlamaIndex for codebase understanding"""
    
    def __init__(self):
        self.index = None
        self.query_engine = None
        self.embed_model = None
        self.llm = None
        self.documents = []
        
    def setup(self):
        """Initialize LlamaIndex components"""
        try:
            # Setup embedding model
            self.embed_model = HuggingFaceEmbedding(
                model_name="sentence-transformers/all-MiniLM-L6-v2"
            )
            
            # Setup LLM
            self.llm = Ollama(model="deepseek-coder", request_timeout=120.0)
            
            # Setup node parser
            node_parser = SentenceSplitter(
                chunk_size=1024,
                chunk_overlap=20
            )
            
            print("✅ LlamaIndex components initialized")
            return True
            
        except Exception as e:
            print(f"❌ Failed to setup LlamaIndex: {e}")
            return False
    
    def load_codebase(self, paths: Dict[str, Path]) -> bool:
        """Load and index the codebase"""
        try:
            all_documents = []
            
            for name, path in paths.items():
                if not path.exists():
                    print(f"⚠️  Path {path} does not exist, skipping...")
                    continue
                
                print(f"📖 Loading {name} codebase from {path}")
                
                # Use SimpleDirectoryReader with exclusions
                reader = SimpleDirectoryReader(
                    input_dir=str(path),
                    recursive=True,
                    exclude=[
                        ".git", "node_modules", ".dart_tool", "build",
                        "dist", "__pycache__", ".vscode", ".idea",
                        "*.lock", "*.log", "*.tmp"
                    ],
                    required_exts=[
                        ".py", ".js", ".ts", ".dart", ".jsx", ".tsx",
                        ".java", ".cpp", ".c", ".h", ".cs", ".go", ".rs",
                        ".json", ".yaml", ".yml", ".md"
                    ]
                )
                
                documents = reader.load_data()
                
                # Add metadata to documents
                for doc in documents:
                    doc.metadata.update({
                        "project": name,
                        "file_path": str(doc.metadata.get("file_path", "")),
                        "file_type": Path(doc.metadata.get("file_path", "")).suffix
                    })
                
                all_documents.extend(documents)
                print(f"✅ Loaded {len(documents)} documents from {name}")
            
            self.documents = all_documents
            print(f"📚 Total documents loaded: {len(all_documents)}")
            
            # Create index
            self.index = VectorStoreIndex.from_documents(
                all_documents,
                embed_model=self.embed_model,
                transformations=[node_parser]
            )
            
            # Create query engine
            self.query_engine = self.index.as_query_engine(
                llm=self.llm,
                similarity_top_k=5
            )
            
            print("✅ Codebase indexed successfully")
            return True
            
        except Exception as e:
            print(f"❌ Failed to load codebase: {e}")
            return False
    
    def query(self, question: str) -> Dict[str, Any]:
        """Query the codebase for information"""
        try:
            if not self.query_engine:
                return {
                    "success": False,
                    "error": "Query engine not initialized"
                }
            
            response = self.query_engine.query(question)
            
            return {
                "success": True,
                "answer": str(response),
                "sources": [node.metadata for node in response.source_nodes],
                "question": question
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "question": question
            }
    
    def search_similar_code(self, code_snippet: str, limit: int = 5) -> Dict[str, Any]:
        """Search for similar code patterns"""
        try:
            if not self.index:
                return {
                    "success": False,
                    "error": "Index not initialized"
                }
            
            # Create a document from the code snippet
            doc = Document(text=code_snippet, metadata={"query_type": "similarity_search"})
            
            # Query for similar documents
            retriever = self.index.as_retriever(similarity_top_k=limit)
            nodes = retriever.retrieve(code_snippet)
            
            results = []
            for node in nodes:
                results.append({
                    "content": node.text[:500] + "..." if len(node.text) > 500 else node.text,
                    "metadata": node.metadata,
                    "score": node.score
                })
            
            return {
                "success": True,
                "results": results,
                "query": code_snippet
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "query": code_snippet
            }
    
    def get_project_summary(self) -> Dict[str, Any]:
        """Get a summary of the loaded project"""
        if not self.documents:
            return {"success": False, "error": "No documents loaded"}
        
        # Analyze documents
        file_types = {}
        projects = {}
        
        for doc in self.documents:
            file_type = doc.metadata.get("file_type", "unknown")
            project = doc.metadata.get("project", "unknown")
            
            file_types[file_type] = file_types.get(file_type, 0) + 1
            projects[project] = projects.get(project, 0) + 1
        
        return {
            "success": True,
            "total_documents": len(self.documents),
            "file_types": file_types,
            "projects": projects,
            "indexed": self.index is not None
        }
    
    def explain_code(self, file_path: str, line_range: str = None) -> Dict[str, Any]:
        """Explain code from a specific file"""
        try:
            # Find documents for the specific file
            file_docs = [
                doc for doc in self.documents 
                if file_path in doc.metadata.get("file_path", "")
            ]
            
            if not file_docs:
                return {
                    "success": False,
                    "error": f"No documents found for file: {file_path}"
                }
            
            # Create context from file documents
            context = "\n".join([doc.text for doc in file_docs])
            
            question = f"Explain the code in {file_path}"
            if line_range:
                question += f", specifically around lines {line_range}"
            
            return self.query(question)
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "file_path": file_path
            }
