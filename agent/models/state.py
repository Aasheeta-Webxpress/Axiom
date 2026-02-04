from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field

class AgentState(BaseModel):
    """Core state for the LangGraph agent"""
    
    # User request and context
    user_request: str = Field(description="Original user request")
    operation_type: Optional[str] = Field(default=None, description="Type of operation: project, api, widget, layout")
    
    # Project context
    project_id: Optional[str] = Field(default=None, description="Current project ID")
    current_screen: Optional[str] = Field(default=None, description="Current screen ID")
    
    # Operation context
    context: Dict[str, Any] = Field(default_factory=dict, description="Operation context and parameters")
    tools_used: List[str] = Field(default_factory=list, description="List of tools used in this operation")
    
    # Results and feedback
    results: List[Dict[str, Any]] = Field(default_factory=list, description="Results from tool executions")
    errors: List[str] = Field(default_factory=list, description="Errors encountered")
    
    # Workflow control
    next_step: Optional[str] = Field(default=None, description="Next step in the workflow")
    completed: bool = Field(default=False, description="Whether the operation is completed")
    waiting_for_user: bool = Field(default=False, description="Whether waiting for user input")
    
    # Memory and learning
    memory_results: List[Dict[str, Any]] = Field(default_factory=list, description="Results from memory searches")
    learned_patterns: List[str] = Field(default_factory=list, description="Patterns learned from this operation")

class ProjectContext(BaseModel):
    """Context for project-specific operations"""
    
    project_id: str
    project_name: str
    screens: List[Dict[str, Any]] = Field(default_factory=list)
    apis: List[Dict[str, Any]] = Field(default_factory=list)
    widgets: Dict[str, List[Dict[str, Any]]] = Field(default_factory=dict)
    collections: List[str] = Field(default_factory=list)

class ApiConfig(BaseModel):
    """Configuration for API generation"""
    
    name: str
    method: str  # GET, POST, PUT, DELETE
    path: str
    purpose: str  # create, read, update, delete, login, register
    collection_name: str
    fields: List[Dict[str, Any]] = Field(default_factory=list)
    auth_required: bool = Field(default=False)
    validation_rules: Dict[str, Any] = Field(default_factory=dict)

class WidgetConfig(BaseModel):
    """Configuration for widget creation"""
    
    type: str  # button, textfield, listview, etc.
    properties: Dict[str, Any] = Field(default_factory=dict)
    position: Dict[str, float] = Field(default_factory=dict)
    api_binding: Optional[str] = Field(default=None)
    event_handlers: Dict[str, Any] = Field(default_factory=dict)
    data_mapping: Dict[str, str] = Field(default_factory=dict)
