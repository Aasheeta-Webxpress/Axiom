from typing import Dict, Any, List, Optional
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolExecutor
from ..models import AgentState
from ..tools import ProjectTools, ApiTools, WidgetTools
from ..memory import LlamaIndexMemory, QdrantMemory
import re

class AxiomAgent:
    """Main agent for Axiom no-code platform automation"""
    
    def __init__(self):
        self.project_tools = ProjectTools()
        self.api_tools = ApiTools()
        self.widget_tools = WidgetTools()
        self.memory = LlamaIndexMemory()
        self.qdrant = QdrantMemory()
        
        # Initialize components
        self.setup_components()
        
        # Create the graph
        self.graph = self.create_graph()
    
    def setup_components(self):
        """Setup all agent components"""
        print("🔧 Setting up agent components...")
        
        # Setup memory systems
        memory_ready = self.memory.setup()
        qdrant_ready = self.qdrant.setup()
        
        if memory_ready:
            # Load codebase into memory
            from ..config import settings
            paths = settings.get_project_paths()
            self.memory.load_codebase(paths)
        
        print("✅ Agent components ready")
    
    def create_graph(self) -> StateGraph:
        """Create the LangGraph workflow"""
        workflow = StateGraph(AgentState)
        
        # Add nodes
        workflow.add_node("parse_intent", self.parse_intent)
        workflow.add_node("search_memory", self.search_memory)
        workflow.add_node("validate_operation", self.validate_operation)
        workflow.add_node("execute_tools", self.execute_tools)
        workflow.add_node("verify_results", self.verify_results)
        workflow.add_node("respond_to_user", self.respond_to_user)
        
        # Add edges
        workflow.set_entry_point("parse_intent")
        workflow.add_edge("parse_intent", "search_memory")
        workflow.add_edge("search_memory", "validate_operation")
        workflow.add_edge("validate_operation", "execute_tools")
        workflow.add_edge("execute_tools", "verify_results")
        workflow.add_edge("verify_results", "respond_to_user")
        workflow.add_edge("respond_to_user", END)
        
        return workflow.compile()
    
    def parse_intent(self, state: AgentState) -> AgentState:
        """Parse user intent and extract operation type"""
        user_request = state.user_request.lower()
        
        # Define intent patterns
        intent_patterns = {
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
            "bind_data": [
                r"connect.*api", r"bind.*data", r"link.*database"
            ],
            "layout": [
                r"arrange", r"position", r"layout", r"organize"
            ]
        }
        
        # Determine operation type
        operation_type = None
        for intent, patterns in intent_patterns.items():
            for pattern in patterns:
                if re.search(pattern, user_request):
                    operation_type = intent
                    break
            if operation_type:
                break
        
        # Extract entities from request
        entities = self.extract_entities(state.user_request)
        
        state.operation_type = operation_type
        state.context.update(entities)
        state.next_step = "search_memory"
        
        return state
    
    def extract_entities(self, user_request: str) -> Dict[str, Any]:
        """Extract entities from user request"""
        entities = {}
        
        # Extract project name
        project_match = re.search(r'(?:project|app)\s+(?:called\s+)?["\']?([^"\']+)["\']?', user_request, re.IGNORECASE)
        if project_match:
            entities["project_name"] = project_match.group(1)
        
        # Extract API/entity names
        entity_match = re.search(r'(?:api|endpoint)\s+(?:for\s+)?(["\']?)([^"\']+)\\1', user_request, re.IGNORECASE)
        if entity_match:
            entities["entity_name"] = entity_match.group(2)
        
        # Extract field definitions
        fields_match = re.search(r'fields?[:\s]+([^.]*)', user_request, re.IGNORECASE)
        if fields_match:
            fields_text = fields_match.group(1)
            entities["fields"] = self.parse_fields(fields_text)
        
        # Extract widget types
        widget_types = ["button", "textfield", "form", "list", "text", "container"]
        for widget_type in widget_types:
            if widget_type in user_request.lower():
                entities.setdefault("widget_types", []).append(widget_type)
        
        return entities
    
    def parse_fields(self, fields_text: str) -> List[Dict[str, Any]]:
        """Parse field definitions from text"""
        fields = []
        
        # Simple pattern matching for field definitions
        # Example: "title (text), description (text), completed (boolean)"
        field_matches = re.findall(r'(\w+)\s*(?:\(([^)]+)\))?', fields_text)
        
        for field_name, field_type in field_matches:
            field = {
                "name": field_name,
                "type": field_type or "text",
                "required": False
            }
            
            # Check if field is marked as required
            if "required" in fields_text.lower() and field_name in fields_text.lower():
                field["required"] = True
            
            fields.append(field)
        
        return fields
    
    def search_memory(self, state: AgentState) -> AgentState:
        """Search memory for relevant information"""
        try:
            # Search for relevant codebase information
            query = f"How to {state.operation_type} in Axiom platform"
            
            memory_result = self.memory.query(query)
            state.memory_results.append(memory_result)
            
        except Exception as e:
            state.errors.append(f"Memory search failed: {str(e)}")
        
        state.next_step = "validate_operation"
        return state
    
    def validate_operation(self, state: AgentState) -> AgentState:
        """Validate if operation can be performed"""
        try:
            # Basic validation based on operation type
            if state.operation_type == "create_project":
                if not state.context.get("project_name"):
                    state.errors.append("Project name is required")
            
            elif state.operation_type == "create_api":
                if not state.context.get("entity_name"):
                    state.errors.append("API/entity name is required")
            
            elif state.operation_type == "add_widget":
                if not state.context.get("widget_types"):
                    state.errors.append("Widget type is required")
                if not state.context.get("project_id"):
                    state.errors.append("Project ID is required for widget operations")
            
            # Set project context if available
            if state.context.get("project_id"):
                state.project_id = state.context["project_id"]
            
        except Exception as e:
            state.errors.append(f"Validation failed: {str(e)}")
        
        state.next_step = "execute_tools"
        return state
    
    def execute_tools(self, state: AgentState) -> AgentState:
        """Execute appropriate tools based on operation"""
        try:
            if state.errors:
                state.next_step = "respond_to_user"
                return state
            
            result = None
            
            if state.operation_type == "create_project":
                result = self.project_tools.create_project(
                    name=state.context.get("project_name", "New Project"),
                    description=state.context.get("description", "")
                )
                state.tools_used.append("create_project")
            
            elif state.operation_type == "create_api":
                if state.context.get("entity_name"):
                    result = self.api_tools.create_crud_api(
                        project_id=state.project_id,
                        entity_name=state.context["entity_name"],
                        fields=state.context.get("fields", [])
                    )
                    state.tools_used.append("create_crud_api")
            
            elif state.operation_type == "add_widget":
                widget_types = state.context.get("widget_types", [])
                for widget_type in widget_types:
                    result = self.widget_tools.add_widget(
                        project_id=state.project_id,
                        screen_id=state.context.get("screen_id", "screen_1"),
                        widget_type=widget_type
                    )
                    state.tools_used.append(f"add_{widget_type}")
            
            if result:
                state.results.append(result)
                if result.get("success"):
                    # Update context with result data
                    if "project_id" in result:
                        state.project_id = result["project_id"]
                        state.context["project_id"] = result["project_id"]
        
        except Exception as e:
            state.errors.append(f"Tool execution failed: {str(e)}")
        
        state.next_step = "verify_results"
        return state
    
    def verify_results(self, state: AgentState) -> AgentState:
        """Verify operation results"""
        try:
            if state.results:
                for result in state.results:
                    if not result.get("success"):
                        state.errors.append(f"Operation failed: {result.get('error', 'Unknown error')}")
            
            # Mark as completed if no errors
            if not state.errors:
                state.completed = True
        
        except Exception as e:
            state.errors.append(f"Verification failed: {str(e)}")
        
        state.next_step = "respond_to_user"
        return state
    
    def respond_to_user(self, state: AgentState) -> AgentState:
        """Generate response for user"""
        # This will be handled by the API layer
        state.next_step = None
        return state
    
    def run(self, user_request: str, project_id: str = None) -> Dict[str, Any]:
        """Run the agent with a user request"""
        initial_state = AgentState(
            user_request=user_request,
            project_id=project_id
        )
        
        try:
            # Run the graph
            final_state = self.graph.invoke(initial_state)
            
            return {
                "success": final_state.completed,
                "results": final_state.results,
                "errors": final_state.errors,
                "tools_used": final_state.tools_used,
                "context": final_state.context,
                "project_id": final_state.project_id
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "results": [],
                "errors": [str(e)]
            }
