#!/usr/bin/env python3
"""
Minimal Axiom Agent - No external dependencies except requests
Works with any Python version
"""

import http.server
import socketserver
import json
import urllib.parse
import re
from urllib.request import urlopen
from typing import Dict, Any, Optional
import sys
import os

# Add current directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import our tools
try:
    from tools.project_tools import ProjectTools
    from tools.api_tools import ApiTools
    from tools.widget_tools import WidgetTools
    from config import settings
    print("✅ All tools imported successfully")
    TOOLS_AVAILABLE = True
except ImportError as e:
    print(f"❌ Tools not available: {e}")
    print("🔧 Checking individual imports...")
    
    try:
        from tools.project_tools import ProjectTools
        print("✅ ProjectTools imported")
    except ImportError as e:
        print(f"❌ ProjectTools failed: {e}")
    
    try:
        from tools.api_tools import ApiTools
        print("✅ ApiTools imported")
    except ImportError as e:
        print(f"❌ ApiTools failed: {e}")
    
    try:
        from tools.widget_tools import WidgetTools
        print("✅ WidgetTools imported")
    except ImportError as e:
        print(f"❌ WidgetTools failed: {e}")
    
    try:
        from config import settings
        print("✅ Settings imported")
    except ImportError as e:
        print(f"❌ Settings failed: {e}")
    
    TOOLS_AVAILABLE = False

class MinimalAgent:
    """Minimal agent using only standard library"""
    
    def __init__(self):
        self.intent_patterns = {
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
        
        # Initialize tools if available
        if TOOLS_AVAILABLE:
            self.project_tools = ProjectTools()
            self.api_tools = ApiTools()
            self.widget_tools = WidgetTools()
    
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
        
        return entities
    
    def process_request(self, message: str, project_id: str = None) -> Dict[str, Any]:
        """Process user request"""
        intent = self.parse_intent(message)
        entities = self.extract_entities(message)
        
        if not TOOLS_AVAILABLE:
            # Fallback responses when tools aren't available
            if intent == "create_project":
                project_name = entities.get("project_name", "New Project")
                return {
                    "success": True,
                    "message": f"✅ Would create project: {project_name}",
                    "project_id": f"demo_project_{hash(message) % 10000}",
                    "note": "Demo mode - tools not available"
                }
            
            elif intent == "create_api":
                entity_name = entities.get("entity_name", "Item")
                return {
                    "success": True,
                    "message": f"✅ Would create CRUD API for: {entity_name}",
                    "note": "Demo mode - tools not available"
                }
            
            elif intent == "add_widget":
                return {
                    "success": True,
                    "message": "✅ Would add widget to screen",
                    "note": "Demo mode - tools not available"
                }
            
            elif intent == "connect_api":
                return {
                    "success": True,
                    "message": "✅ Would connect submit button to API",
                    "note": "Demo mode - tools not available"
                }
            
            elif intent == "list_projects":
                return {
                    "success": True,
                    "message": "📋 Demo Projects: [Task Manager, Notes App, Todo List]",
                    "projects": ["Task Manager", "Notes App", "Todo List"],
                    "note": "Demo mode - tools not available"
                }
            
            else:
                return {
                    "success": False,
                    "error": f"I don't understand: {message}. Try: 'Create a new project called My App'"
                }
        
        try:
            if intent == "create_project":
                project_name = entities.get("project_name", "New Project")
                result = self.project_tools.create_project(
                    name=project_name,
                    description=f"Project created by agent: {message}"
                )
                return result
            
            elif intent == "create_api":
                if not project_id:
                    return {
                        "success": False,
                        "error": "Please specify a project ID first. Create a project first."
                    }
                
                entity_name = entities.get("entity_name", "Item")
                # Simple fields for demo
                fields = [
                    {"name": "title", "type": "text", "required": True},
                    {"name": "description", "type": "text", "required": False}
                ]
                
                result = self.api_tools.create_crud_api(
                    project_id=project_id,
                    entity_name=entity_name,
                    fields=fields
                )
                return result
            
            elif intent == "add_widget":
                if not project_id:
                    return {
                        "success": False,
                        "error": "Please specify a project ID first. Create a project first."
                    }
                
                # Add a simple button by default
                result = self.widget_tools.add_widget(
                    project_id=project_id,
                    screen_id="screen_1",
                    widget_type="button",
                    properties={"text": "Submit Button"}
                )
                return result
            
            elif intent == "list_projects":
                result = self.project_tools.list_projects()
                return result
            
            else:
                return {
                    "success": False,
                    "error": f"I don't understand: {message}. Try: 'Create a new project called My App'"
                }
        
        except Exception as e:
            return {
                "success": False,
                "error": f"Error processing request: {str(e)}"
            }

class AgentHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler for the agent"""
    
    def __init__(self, *args, **kwargs):
        self.agent = MinimalAgent()
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {"message": "Axiom Minimal Agent API is running"}
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {
                "status": "healthy",
                "agent_ready": True,
                "version": "minimal",
                "tools_available": TOOLS_AVAILABLE
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/projects':
            try:
                result = self.agent.process_request("list projects")
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
                    "message": "Operation completed successfully" if result.get("success") else "Operation failed",
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
    """Run the minimal agent server"""
    PORT = settings.AGENT_PORT if TOOLS_AVAILABLE else 8000
    HOST = settings.AGENT_HOST if TOOLS_AVAILABLE else 'localhost'
    
    print("🚀 Starting Axiom Minimal Agent...")
    print("📡 Agent will be available at: http://{}:{}".format(HOST, PORT))
    print("🌐 Frontend: Open frontend/index.html in your browser")
    print("✅ No external dependencies needed!")
    print("🔧 Tools available:", TOOLS_AVAILABLE)
    
    with socketserver.TCPServer((HOST, PORT), AgentHTTPRequestHandler) as httpd:
        print(f"🎯 Server running at http://{HOST}:{PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n⏹️  Server stopped by user")

if __name__ == "__main__":
    run_server()
