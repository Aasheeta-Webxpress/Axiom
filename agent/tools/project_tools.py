import requests
import json
from typing import Dict, Any, List, Optional
from ..config import settings
from ..models import ProjectContext, ApiConfig

class ProjectTools:
    """Tools for managing Axiom projects"""
    
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
    
    def create_project(self, name: str, description: str = "") -> Dict[str, Any]:
        """Create a new Axiom project"""
        try:
            url = f"{self.api_base}/projects"
            data = {
                "name": name,
                "description": description
            }
            
            response = requests.post(url, json=data, headers=self._get_headers())
            
            if response.status_code == 201:
                project = response.json()
                return {
                    "success": True,
                    "project": project,
                    "project_id": project["_id"],
                    "message": f"Project '{name}' created successfully"
                }
            else:
                return {
                    "success": False,
                    "error": response.json().get("error", "Unknown error"),
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def load_project(self, project_id: str) -> Dict[str, Any]:
        """Load an existing project"""
        try:
            url = f"{self.api_base}/projects/{project_id}"
            response = requests.get(url, headers=self._get_headers())
            
            if response.status_code == 200:
                project = response.json()
                return {
                    "success": True,
                    "project": project,
                    "project_context": self._create_project_context(project)
                }
            else:
                return {
                    "success": False,
                    "error": response.json().get("error", "Project not found"),
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def update_project(self, project_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        """Update project with new data"""
        try:
            url = f"{self.api_base}/projects/{project_id}"
            response = requests.put(url, json=updates, headers=self._get_headers())
            
            if response.status_code == 200:
                project = response.json()
                return {
                    "success": True,
                    "project": project,
                    "message": "Project updated successfully"
                }
            else:
                return {
                    "success": False,
                    "error": response.json().get("error", "Update failed"),
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def add_screen(self, project_id: str, screen_name: str, route: str = None) -> Dict[str, Any]:
        """Add a new screen to the project"""
        try:
            # First load current project
            load_result = self.load_project(project_id)
            if not load_result["success"]:
                return load_result
            
            project = load_result["project"]
            
            # Generate screen ID and route
            screen_id = f"screen_{len(project.get('screens', [])) + 1}"
            if not route:
                route = f"/{screen_name.lower().replace(' ', '_')}"
            
            # Add new screen
            new_screen = {
                "id": screen_id,
                "name": screen_name,
                "route": route,
                "widgets": []
            }
            
            if "screens" not in project:
                project["screens"] = []
            
            project["screens"].append(new_screen)
            
            # Update project
            return self.update_project(project_id, project)
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_project_structure(self, project_id: str) -> Dict[str, Any]:
        """Get complete project structure"""
        load_result = self.load_project(project_id)
        if not load_result["success"]:
            return load_result
        
        project = load_result["project"]
        
        return {
            "success": True,
            "structure": {
                "project_id": project["_id"],
                "name": project.get("name", "Unknown"),
                "description": project.get("description", ""),
                "screens": project.get("screens", []),
                "apis": project.get("apis", []),
                "collections": project.get("collections", []),
                "created_at": project.get("createdAt"),
                "updated_at": project.get("updatedAt")
            }
        }
    
    def _create_project_context(self, project: Dict[str, Any]) -> ProjectContext:
        """Create ProjectContext from project data"""
        screens = project.get("screens", [])
        apis = project.get("apis", [])
        collections = project.get("collections", [])
        
        # Organize widgets by screen
        widgets = {}
        for screen in screens:
            widgets[screen["id"]] = screen.get("widgets", [])
        
        return ProjectContext(
            project_id=project["_id"],
            project_name=project.get("name", "Unknown"),
            screens=screens,
            apis=apis,
            widgets=widgets,
            collections=collections
        )
    
    def list_projects(self) -> Dict[str, Any]:
        """List all projects for the user"""
        try:
            url = f"{self.api_base}/projects"
            response = requests.get(url, headers=self._get_headers())
            
            if response.status_code == 200:
                projects = response.json()
                return {
                    "success": True,
                    "projects": projects,
                    "count": len(projects)
                }
            else:
                return {
                    "success": False,
                    "error": response.json().get("error", "Failed to load projects"),
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def delete_project(self, project_id: str) -> Dict[str, Any]:
        """Delete a project"""
        try:
            url = f"{self.api_base}/projects/{project_id}"
            response = requests.delete(url, headers=self._get_headers())
            
            if response.status_code == 200:
                return {
                    "success": True,
                    "message": "Project deleted successfully"
                }
            else:
                return {
                    "success": False,
                    "error": response.json().get("error", "Delete failed"),
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
