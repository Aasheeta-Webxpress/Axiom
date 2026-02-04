import requests
import json
import uuid
from typing import Dict, Any, List, Optional
from ..config import settings

class WidgetTools:
    """Tools for creating and managing widgets in Axiom projects"""
    
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
    
    def _get_default_properties(self, widget_type: str) -> Dict[str, Any]:
        """Get default properties for widget type"""
        defaults = {
            "button": {"text": "Button", "style": "elevated"},
            "textfield": {"label": "Text Field", "placeholder": "Enter text"},
            "text": {"text": "Text", "style": "body1"},
            "container": {"padding": 16},
            "listview": {"itemCount": 10}
        }
        return defaults.get(widget_type.lower(), {})
    
    def add_widget(self, project_id: str, screen_id: str, widget_type: str, properties: Dict[str, Any] = None) -> Dict[str, Any]:
        """Add a widget to a screen"""
        try:
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {"success": False, "error": "Failed to load project"}
            
            project = project_response.json()
            
            # Find screen
            screen = next((s for s in project.get("screens", []) if s["id"] == screen_id), None)
            if not screen:
                return {"success": False, "error": f"Screen {screen_id} not found"}
            
            # Create widget
            widget_id = f"widget_{uuid.uuid4().hex[:8]}"
            widget = {
                "id": widget_id,
                "type": widget_type.lower(),
                "properties": properties or self._get_default_properties(widget_type),
                "children": [],
                "position": {"x": 0, "y": 0},
                "parent": None
            }
            
            screen.setdefault("widgets", []).append(widget)
            
            # Update project
            update_response = requests.put(project_url, json=project, headers=self._get_headers())
            
            if update_response.status_code == 200:
                return {
                    "success": True,
                    "widget": widget,
                    "widget_id": widget_id,
                    "message": f"{widget_type} widget added"
                }
            else:
                return {"success": False, "error": "Failed to add widget"}
                
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def position_widget(self, project_id: str, screen_id: str, widget_id: str, x: float, y: float) -> Dict[str, Any]:
        """Position widget at coordinates"""
        return self.update_widget(project_id, screen_id, widget_id, {"position": {"x": x, "y": y}})
    
    def update_widget(self, project_id: str, screen_id: str, widget_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        """Update widget properties"""
        try:
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {"success": False, "error": "Failed to load project"}
            
            project = project_response.json()
            
            # Find widget
            widget = None
            for screen in project.get("screens", []):
                if screen["id"] == screen_id:
                    for w in screen.get("widgets", []):
                        if w["id"] == widget_id:
                            widget = w
                            break
                    break
            
            if not widget:
                return {"success": False, "error": f"Widget {widget_id} not found"}
            
            widget.update(updates)
            
            update_response = requests.put(project_url, json=project, headers=self._get_headers())
            
            if update_response.status_code == 200:
                return {"success": True, "widget": widget, "message": "Widget updated"}
            else:
                return {"success": False, "error": "Failed to update widget"}
                
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def bind_widget_to_api(self, project_id: str, screen_id: str, widget_id: str, api_endpoint_id: str) -> Dict[str, Any]:
        """Bind widget to API endpoint"""
        try:
            project_url = f"{self.api_base}/projects/{project_id}"
            project_response = requests.get(project_url, headers=self._get_headers())
            
            if project_response.status_code != 200:
                return {"success": False, "error": "Failed to load project"}
            
            project = project_response.json()
            
            # Find API
            api_config = next((api for api in project.get("apis", []) 
                             if api.get("id") == api_endpoint_id or api.get("name") == api_endpoint_id), None)
            
            if not api_config:
                return {"success": False, "error": f"API {api_endpoint_id} not found"}
            
            # Create binding
            event_binding = {
                "action": "api_call",
                "apiEndpoint": api_config["path"],
                "apiMethod": api_config["method"]
            }
            
            updates = {
                "apiEndpointId": api_endpoint_id,
                "apiMethod": api_config["method"],
                "apiPath": api_config["path"],
                "requiresAuth": api_config.get("auth", False),
                "onClick": event_binding
            }
            
            return self.update_widget(project_id, screen_id, widget_id, updates)
            
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def create_form(self, project_id: str, screen_id: str, fields: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Create form with multiple fields"""
        try:
            results = []
            current_y = 50
            
            for field in fields:
                field_name = field.get("name", f"field_{len(results)}")
                field_label = field.get("label", field_name.title())
                
                widget_result = self.add_widget(project_id, screen_id, "textfield", {
                    "label": field_label,
                    "placeholder": f"Enter {field_label}",
                    "name": field_name,
                    "required": field.get("required", False)
                })
                
                if widget_result["success"]:
                    self.position_widget(project_id, screen_id, widget_result["widget_id"], 50, current_y)
                    results.append(widget_result)
                    current_y += 80
            
            # Add submit button
            button_result = self.add_widget(project_id, screen_id, "button", {"text": "Submit"})
            if button_result["success"]:
                self.position_widget(project_id, screen_id, button_result["widget_id"], 50, current_y)
                results.append(button_result)
            
            return {
                "success": True,
                "widgets": results,
                "message": f"Form with {len(fields)} fields created"
            }
            
        except Exception as e:
            return {"success": False, "error": str(e)}
