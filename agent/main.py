from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import os

app = FastAPI(title="Axiom Agent", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Axiom Agent is running"}

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "axiom-agent"}

if __name__ == "__main__":
    port = int(os.getenv("AGENT_PORT", 8000))
    host = os.getenv("AGENT_HOST", "0.0.0.0")
    uvicorn.run(app, host=host, port=port)
