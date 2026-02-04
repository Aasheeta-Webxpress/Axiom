from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
import numpy as np
from typing import List, Dict, Any, Optional
import uuid

class QdrantMemory:
    """Long-term memory using Qdrant vector database"""
    
    def __init__(self, url: str = "http://localhost:6333", collection_name: str = "axiom_codebase"):
        self.client = QdrantClient(url=url)
        self.collection_name = collection_name
        self.collection_exists = False
        
    def setup(self) -> bool:
        """Initialize Qdrant collection"""
        try:
            # Check if collection exists
            collections = self.client.get_collections().collections
            collection_names = [c.name for c in collections]
            
            if self.collection_name not in collection_names:
                # Create collection
                self.client.create_collection(
                    collection_name=self.collection_name,
                    vectors_config=VectorParams(
                        size=384,  # Size for sentence-transformers embeddings
                        distance=Distance.COSINE
                    )
                )
                print(f"✅ Created Qdrant collection: {self.collection_name}")
            else:
                print(f"✅ Qdrant collection exists: {self.collection_name}")
            
            self.collection_exists = True
            return True
            
        except Exception as e:
            print(f"❌ Failed to setup Qdrant: {e}")
            return False
    
    def add_embeddings(self, embeddings: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Add embeddings to the collection"""
        try:
            points = []
            
            for item in embeddings:
                point = PointStruct(
                    id=str(uuid.uuid4()),
                    vector=item["embedding"],
                    payload={
                        "text": item["text"],
                        "file_path": item.get("file_path", ""),
                        "project": item.get("project", ""),
                        "file_type": item.get("file_type", ""),
                        "metadata": item.get("metadata", {})
                    }
                )
                points.append(point)
            
            # Upload points in batches
            batch_size = 100
            for i in range(0, len(points), batch_size):
                batch = points[i:i + batch_size]
                self.client.upsert(
                    collection_name=self.collection_name,
                    points=batch
                )
            
            return {
                "success": True,
                "points_added": len(points),
                "message": f"Added {len(points)} embeddings to collection"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def search(self, query_embedding: List[float], limit: int = 5, 
               score_threshold: float = 0.7) -> Dict[str, Any]:
        """Search for similar embeddings"""
        try:
            search_result = self.client.search(
                collection_name=self.collection_name,
                query_vector=query_embedding,
                limit=limit,
                score_threshold=score_threshold
            )
            
            results = []
            for hit in search_result:
                results.append({
                    "id": hit.id,
                    "score": hit.score,
                    "payload": hit.payload
                })
            
            return {
                "success": True,
                "results": results,
                "count": len(results)
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_collection_info(self) -> Dict[str, Any]:
        """Get information about the collection"""
        try:
            info = self.client.get_collection(self.collection_name)
            
            return {
                "success": True,
                "vectors_count": info.vectors_count,
                "indexed_vectors_count": info.indexed_vectors_count,
                "points_count": info.points_count,
                "status": info.status
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def delete_collection(self) -> Dict[str, Any]:
        """Delete the entire collection"""
        try:
            self.client.delete_collection(self.collection_name)
            self.collection_exists = False
            
            return {
                "success": True,
                "message": f"Collection {self.collection_name} deleted"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def search_by_metadata(self, metadata_filter: Dict[str, Any], 
                          limit: int = 10) -> Dict[str, Any]:
        """Search documents by metadata filters"""
        try:
            # Build filter from metadata
            filter_conditions = []
            
            for key, value in metadata_filter.items():
                filter_conditions.append({
                    "key": key,
                    "match": {"value": value}
                })
            
            search_result = self.client.scroll(
                collection_name=self.collection_name,
                scroll_filter={
                    "must": filter_conditions
                },
                limit=limit
            )
            
            points = search_result[0]  # First element contains points
            
            results = []
            for point in points:
                results.append({
                    "id": point.id,
                    "payload": point.payload
                })
            
            return {
                "success": True,
                "results": results,
                "count": len(results)
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
