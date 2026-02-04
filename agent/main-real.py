#!/usr/bin/env python3
"""
Real Axiom Agent - Actually creates projects in your database
Direct backend connection without complex tool dependencies
"""

import http.server
import socketserver
import json
import urllib.parse
import re
import requests
from typing import Dict, Any, Optional
import sys
import os

# Backend configuration
BACKEND_URL = "http://localhost:5000"
BACKEND_API_BASE = f"{BACKEND_URL}/api"

# Authentication
AUTH_TOKEN = None  # Will be set after login
USER_ID = None    # Will be set after login

class RealAxiomAgent:
    """Agent that actually creates projects in your database"""
    
    def __init__(self):
        self.intent_patterns = {
            "login": [
                r"login", r"sign in", r"authenticate",
                r"login as", r"login with"
            ],
            "create_project": [
                r"create (a )?(new )?project", r"new (app|project)", 
                r"build (a )?(new )?app", r"make (a )?(new )?project"
            ],
            "create_api": [
                r"create (a )?(new )?api", r"add endpoint", 
                r"new api", r"make api", r"crud api"
            ],
            "add_widget": [
                r"add (a )?(button|form|field|widget)", r"create (a )?(button|form|field)",
                r"insert (a )?(button|form|field|widget)"
            ],
            "list_projects": [
                r"list projects", r"show projects", r"get projects",
                r"show me all projects", r"show all projects"
            ],
            "connect_api": [
                r"connect.*button.*api", r"connect.*submit.*api",
                r"bind.*button.*api", r"link.*widget.*api"
            ]
        }
    
    def parse_intent(self, message: str) -> str:
        """Parse user intent using simple patterns"""
        message_lower = message.lower()
        
        for intent, patterns in self.intent_patterns.items():
            for pattern in patterns:
                if re.search(pattern, message_lower):
                    return intent
        
        return "unknown"
    
    def extract_entities(self, message: str) -> Dict[str, Any]:
        """Extract entities from message"""
        entities = {}
        
        # Extract project name
        project_match = re.search(r'(?:project|app)\s+(?:called\s+)?["\']?([^"\']+)["\']?', message, re.IGNORECASE)
        if project_match:
            entities["project_name"] = project_match.group(1)
        
        # Extract API/entity names
        entity_match = re.search(r'(?:api|endpoint)\s+(?:for\s+)?(["\']?)([^"\']+)\\1', message, re.IGNORECASE)
        if entity_match:
            entities["entity_name"] = entity_match.group(2)
        
        # Extract login credentials
        login_match = re.search(r'login\s+(?:as\s+)?(\S+)\s+(?:with\s+)?(\S+)', message, re.IGNORECASE)
        if login_match:
            entities["email"] = login_match.group(1)
            entities["password"] = login_match.group(2)
        
        return entities
    
    def _get_headers(self) -> Dict[str, str]:
        """Get headers for API requests"""
        headers = {"Content-Type": "application/json"}
        if AUTH_TOKEN:
            headers["Authorization"] = f"Bearer {AUTH_TOKEN}"
        return headers
    
    def login(self, email: str, password: str) -> Dict[str, Any]:
        """Login to get authentication token from your database"""
        global AUTH_TOKEN, USER_ID
        
        try:
            # Use your exact auth endpoint
            url = f"{BACKEND_API_BASE}/auth/login"
            data = {"email": email, "password": password}
            
            response = requests.post(url, json=data, timeout=10)
            
            if response.status_code == 200:
                result = response.json()
                print(f"🔍 Login response: {result}")  # Debug line
                if "token" in result and "user" in result:
                    AUTH_TOKEN = result["token"]
                    USER_ID = result["user"]["id"]  # Your Flutter uses user.id
                    return {
                        "success": True,
                        "message": f"✅ Login successful! Welcome {result['user']['name']}",
                        "token": AUTH_TOKEN,
                        "user_id": USER_ID,
                        "user": result["user"]
                    }
                else:
                    return {
                        "success": False,
                        "error": f"Invalid response format from server. Got: {result}"
                    }
            else:
                print(f"❌ Login failed with status: {response.status_code}")
                print(f"❌ Response body: {response.text}")
                error_data = response.json() if response.headers.get('content-type') == 'application/json' else {}
                return {
                    "success": False,
                    "error": error_data.get("error", f"Login failed: {response.status_code} - {response.text}")
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Login error: {str(e)}"
            }
    
    def create_project_real(self, name: str, description: str = "") -> Dict[str, Any]:
        """Actually create project in your database"""
        try:
            url = f"{BACKEND_API_BASE}/projects"
            data = {
                "name": name,
                "description": description
            }
            
            response = requests.post(url, json=data, headers=self._get_headers(), timeout=10)
            
            if response.status_code == 201:
                project = response.json()
                return {
                    "success": True,
                    "project": project,
                    "project_id": project["_id"],
                    "message": f"✅ Project '{name}' created successfully in database!"
                }
            else:
                error_data = response.json() if response.headers.get('content-type') == 'application/json' else {}
                return {
                    "success": False,
                    "error": error_data.get("error", "Unknown error"),
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def list_projects_real(self) -> Dict[str, Any]:
        """Actually list projects from your database"""
        try:
            url = f"{BACKEND_API_BASE}/projects"
            response = requests.get(url, headers=self._get_headers(), timeout=10)
            
            if response.status_code == 200:
                projects = response.json()
                project_names = [p.get("name", "Unknown") for p in projects]
                return {
                    "success": True,
                    "projects": projects,
                    "project_names": project_names,
                    "count": len(projects),
                    "message": f"📋 Found {len(projects)} projects in database"
                }
            else:
                return {
                    "success": False,
                    "error": response.json().get("error", "Unknown error")
                }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def create_api_real(self, project_id: str, entity_name: str) -> Dict[str, Any]:
        """Actually create API in your database"""
        try:
            # First get current project
            url = f"{BACKEND_API_BASE}/projects/{project_id}"
            response = requests.get(url, headers=self._get_headers(), timeout=10)
            
            if response.status_code != 200:
                return {
                    "success": False,
                    "error": "Project not found"
                }
            
            project = response.json()
            
            # Create CRUD APIs
            collection_name = entity_name.lower().replace(' ', '_')
            apis = [
                {
                    "name": f"Get {entity_name}",
                    "method": "GET",
                    "path": f"/{collection_name}",
                    "purpose": "read",
                    "collectionName": collection_name,
                    "fields": [],
                    "auth": False
                },
                {
                    "name": f"Create {entity_name}",
                    "method": "POST",
                    "path": f"/{collection_name}",
                    "purpose": "create",
                    "collectionName": collection_name,
                    "fields": [
                        {"name": "title", "type": "text", "required": True},
                        {"name": "description", "type": "text", "required": False}
                    ],
                    "auth": False
                }
            ]
            
            # Add APIs to project
            if "apis" not in project:
                project["apis"] = []
            
            project["apis"].extend(apis)
            
            # Add collection if not exists
            if "collections" not in project:
                project["collections"] = []
            
            if collection_name not in project["collections"]:
                project["collections"].append(collection_name)
            
            # Update project
            update_response = requests.put(url, json=project, headers=self._get_headers(), timeout=10)
            
            if update_response.status_code == 200:
                return {
                    "success": True,
                    "apis": apis,
                    "collection_name": collection_name,
                    "message": f"✅ CRUD API for {entity_name} created in database!"
                }
            else:
                return {
                    "success": False,
                    "error": "Failed to update project"
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def process_request(self, message: str, project_id: str = None) -> Dict[str, Any]:
        """Process user request with real database operations"""
        intent = self.parse_intent(message)
        entities = self.extract_entities(message)
        
        try:
            if intent == "login":
                email = entities.get("email")
                password = entities.get("password")
                
                if not email or not password:
                    return {
                        "success": False,
                        "error": "Please provide email and password. Try: 'login as your@email.com with yourpassword'"
                    }
                
                result = self.login(email, password)
                return result
            
            elif intent == "create_project":
                if not AUTH_TOKEN:
                    return {
                        "success": False,
                        "error": "Please login first. Try: 'login as your@email.com with yourpassword'"
                    }
                
                project_name = entities.get("project_name", "New Project")
                result = self.create_project_real(
                    name=project_name,
                    description=f"Project created by AI agent: {message}"
                )
                return result
            
            elif intent == "list_projects":
                if not AUTH_TOKEN:
                    return {
                        "success": False,
                        "error": "Please login first. Try: 'login as your@email.com with yourpassword'"
                    }
                
                result = self.list_projects_real()
                return result
            
            elif intent == "create_api":
                if not AUTH_TOKEN:
                    return {
                        "success": False,
                        "error": "Please login first. Try: 'login as your@email.com with yourpassword'"
                    }
                
                if not project_id:
                    return {
                        "success": False,
                        "error": "Please create a project first, then I can add APIs to it."
                    }
                
                entity_name = entities.get("entity_name", "Item")
                result = self.create_api_real(project_id, entity_name)
                return result
            
            elif intent == "add_widget":
                if not AUTH_TOKEN:
                    return {
                        "success": False,
                        "error": "Please login first. Try: 'login as your@email.com with yourpassword'"
                    }
                
                return {
                    "success": True,
                    "message": "✅ Widget would be added to project screen",
                    "note": "Widget creation needs more implementation"
                }
            
            elif intent == "connect_api":
                return {
                    "success": True,
                    "message": "✅ API connection would be configured",
                    "note": "API binding needs more implementation"
                }
            
            else:
                return {
                    "success": False,
                    "error": f"I don't understand: {message}. Try: 'login as your@email.com with yourpassword' or 'Create a new project called My App'"
                }
        
        except Exception as e:
            return {
                "success": False,
                "error": f"Error processing request: {str(e)}"
            }

class RealAgentHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler for the real agent"""
    
    def __init__(self, *args, **kwargs):
        self.agent = RealAxiomAgent()
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {"message": "Axiom Real Agent API is running - Creates actual projects!"}
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {
                "status": "healthy",
                "agent_ready": True,
                "version": "real-database",
                "backend_url": BACKEND_URL
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/projects':
            try:
                result = self.agent.list_projects_real()
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps(result).encode())
            except Exception as e:
                self.send_error(500, str(e))
        
        else:
            self.send_error(404, "Not Found")
    
    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/chat':
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                message = data.get('message', '')
                project_id = data.get('project_id')
                
                result = self.agent.process_request(message, project_id)
                
                response = {
                    "success": result.get("success", False),
                    "message": result.get("message", "Operation completed"),
                    "data": result if result.get("success") else None,
                    "error": result.get("error") if not result.get("success") else None
                }
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps(response).encode())
                
            except Exception as e:
                self.send_error(500, str(e))
        
        else:
            self.send_error(404, "Not Found")
    
    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

def run_server():
    """Run the real agent server"""
    PORT = 8000
    HOST = 'localhost'
    
    print("🚀 Starting Axiom REAL Agent...")
    print("📡 Agent will be available at: http://{}:{}".format(HOST, PORT))
    print("🗄️  Creates ACTUAL projects in your database!")
    print("🔗 Backend:", BACKEND_URL)
    print("🌐 Frontend: Open your Flutter app")
    
    with socketserver.TCPServer((HOST, PORT), RealAgentHTTPRequestHandler) as httpd:
        print(f"🎯 Server running at http://{HOST}:{PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n⏹️  Server stopped by user")

if __name__ == "__main__":
    run_server()
