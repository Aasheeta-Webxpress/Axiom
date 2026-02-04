import requests
import json
from typing import Dict, Any, List, Optional
from ..config import settings
from ..models import ApiConfig

class ApiTools:
    """Tools for creating and managing APIs in Axiom projects"""
    
    def __init__(self):
        self.api_base = settings.BACKEND_API_BASE
        self.auth_token = None
    
    def set_auth_token(self, token: str):
        """Set authentication token for API calls"""
        self.auth_token = token
    
    def _get_headers(self) -> Dict[str, str]:
        """Get headers for API requests"""
        headers = {"Content-Type": "application/json"}
        if self.auth_token:
            headers["Authorization"] = f"Bearer {self.auth_token}"
        return headers
    
    def create_crud_api(self, project_id: str, entity_name: str, fields: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Create complete CRUD API for an entity"""
        try:
            # Load current project
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {
                    "success": False,
                    "error": "Failed to load project"
                }
            
            project = project_response.json()
            
            # Generate collection name
            collection_name = entity_name.lower().replace(' ', '_')
            
            # Create CRUD endpoints
            crud_apis = [
                {
                    "name": f"Get {entity_name}",
                    "method": "GET",
                    "path": f"/{collection_name}",
                    "purpose": "read",
                    "collectionName": collection_name,
                    "fields": fields,
                    "auth": False
                },
                {
                    "name": f"Create {entity_name}",
                    "method": "POST", 
                    "path": f"/{collection_name}",
                    "purpose": "create",
                    "collectionName": collection_name,
                    "fields": fields,
                    "auth": False
                },
                {
                    "name": f"Update {entity_name}",
                    "method": "PUT",
                    "path": f"/{collection_name}",
                    "purpose": "update", 
                    "collectionName": collection_name,
                    "fields": fields,
                    "auth": False
                },
                {
                    "name": f"Delete {entity_name}",
                    "method": "DELETE",
                    "path": f"/{collection_name}",
                    "purpose": "delete",
                    "collectionName": collection_name,
                    "fields": fields,
                    "auth": False
                }
            ]
            
            # Add APIs to project
            if "apis" not in project:
                project["apis"] = []
            
            project["apis"].extend(crud_apis)
            
            # Add collection if not exists
            if "collections" not in project:
                project["collections"] = []
            
            if collection_name not in project["collections"]:
                project["collections"].append(collection_name)
            
            # Update project
            update_url = f"{self.api_base}/projects/{project_id}"
            update_response = requests.put(update_url, json=project, headers=self._get_headers())
            
            if update_response.status_code == 200:
                return {
                    "success": True,
                    "apis": crud_apis,
                    "collection_name": collection_name,
                    "message": f"CRUD API for {entity_name} created successfully"
                }
            else:
                return {
                    "success": False,
                    "error": update_response.json().get("error", "Failed to create APIs")
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def create_custom_api(self, project_id: str, api_config: ApiConfig) -> Dict[str, Any]:
        """Create a custom API with specific configuration"""
        try:
            # Load current project
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {
                    "success": False,
                    "error": "Failed to load project"
                }
            
            project = project_response.json()
            
            # Add API to project
            if "apis" not in project:
                project["apis"] = []
            
            api_data = {
                "name": api_config.name,
                "method": api_config.method,
                "path": api_config.path,
                "purpose": api_config.purpose,
                "collectionName": api_config.collection_name,
                "fields": api_config.fields,
                "auth": api_config.auth_required
            }
            
            if api_config.validation_rules:
                api_data["validation"] = api_config.validation_rules
            
            project["apis"].append(api_data)
            
            # Add collection if not exists
            if "collections" not in project:
                project["collections"] = []
            
            if api_config.collection_name not in project["collections"]:
                project["collections"].append(api_config.collection_name)
            
            # Update project
            update_url = f"{self.api_base}/projects/{project_id}"
            update_response = requests.put(update_url, json=project, headers=self._get_headers())
            
            if update_response.status_code == 200:
                return {
                    "success": True,
                    "api": api_data,
                    "message": f"API '{api_config.name}' created successfully"
                }
            else:
                return {
                    "success": False,
                    "error": update_response.json().get("error", "Failed to create API")
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def create_auth_apis(self, project_id: str, collection_name: str = "users") -> Dict[str, Any]:
        """Create authentication APIs (register, login)"""
        try:
            # Load current project
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {
                    "success": False,
                    "error": "Failed to load project"
                }
            
            project = project_response.json()
            
            # User fields for auth
            user_fields = [
                {"name": "email", "type": "email", "required": True},
                {"name": "password", "type": "password", "required": True},
                {"name": "name", "type": "text", "required": False}
            ]
            
            # Auth APIs
            auth_apis = [
                {
                    "name": "User Registration",
                    "method": "POST",
                    "path": "/register",
                    "purpose": "register",
                    "collectionName": collection_name,
                    "fields": user_fields,
                    "auth": False
                },
                {
                    "name": "User Login",
                    "method": "POST", 
                    "path": "/login",
                    "purpose": "login",
                    "collectionName": collection_name,
                    "fields": user_fields,
                    "auth": False
                }
            ]
            
            # Add APIs to project
            if "apis" not in project:
                project["apis"] = []
            
            project["apis"].extend(auth_apis)
            
            # Add collection if not exists
            if "collections" not in project:
                project["collections"] = []
            
            if collection_name not in project["collections"]:
                project["collections"].append(collection_name)
            
            # Update project
            update_url = f"{self.api_base}/projects/{project_id}"
            update_response = requests.put(update_url, json=project, headers=self._get_headers())
            
            if update_response.status_code == 200:
                return {
                    "success": True,
                    "apis": auth_apis,
                    "collection_name": collection_name,
                    "message": "Authentication APIs created successfully"
                }
            else:
                return {
                    "success": False,
                    "error": update_response.json().get("error", "Failed to create auth APIs")
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def test_api_endpoint(self, project_id: str, api_path: str, method: str = "GET", data: Dict[str, Any] = None) -> Dict[str, Any]:
        """Test an API endpoint"""
        try:
            url = f"{self.api_base}{api_path}"
            headers = self._get_headers()
            
            if method.upper() == "GET":
                response = requests.get(url, headers=headers)
            elif method.upper() == "POST":
                response = requests.post(url, json=data or {}, headers=headers)
            elif method.upper() == "PUT":
                response = requests.put(url, json=data or {}, headers=headers)
            elif method.upper() == "DELETE":
                response = requests.delete(url, headers=headers)
            else:
                return {
                    "success": False,
                    "error": f"Unsupported method: {method}"
                }
            
            return {
                "success": True,
                "status_code": response.status_code,
                "response": response.json() if response.content else {},
                "message": f"API test completed with status {response.status_code}"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_api_list(self, project_id: str) -> Dict[str, Any]:
        """Get list of all APIs in a project"""
        try:
            project_url = f"{self.api_base}/projects/{project_id}"
            response = requests.get(project_url, headers=self._get_headers())
            
            if response.status_code == 200:
                project = response.json()
                apis = project.get("apis", [])
                
                return {
                    "success": True,
                    "apis": apis,
                    "count": len(apis)
                }
            else:
                return {
                    "success": False,
                    "error": "Failed to load project APIs"
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def add_validation(self, project_id: str, api_path: str, validation_rules: Dict[str, Any]) -> Dict[str, Any]:
        """Add validation rules to an existing API"""
        try:
            # Load project
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {
                    "success": False,
                    "error": "Failed to load project"
                }
            
            project = project_response.json()
            
            # Find and update the API
            api_found = False
            for api in project.get("apis", []):
                if api["path"] == api_path:
                    api["validation"] = validation_rules
                    api_found = True
                    break
            
            if not api_found:
                return {
                    "success": False,
                    "error": f"API with path {api_path} not found"
                }
            
            # Update project
            update_url = f"{self.api_base}/projects/{project_id}"
            update_response = requests.put(update_url, json=project, headers=self._get_headers())
            
            if update_response.status_code == 200:
                return {
                    "success": True,
                    "message": f"Validation rules added to {api_path}"
                }
            else:
                return {
                    "success": False,
                    "error": "Failed to update API validation"
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
