# Multimodal RAG Incident Analyzer for DevOps

An AI-powered incident diagnosis system that analyzes system logs and dashboard screenshots using a Retrieval-Augmented Generation (RAG) pipeline.

## Architecture Highlights
- **FastAPI Backend**: Asynchronous API parsing inputs and orchestrating RAG.
- **Multimodal Embeddings**: Uses SentenceTransformers (`all-MiniLM-L6-v2`) for text and OpenAI CLIP (`ViT-B/32`) for image understanding.
- **Vector Database**: Qdrant running locally via Docker.
- **Reasoning Engine**: OpenAI `gpt-4o-mini` with a robust heuristic fallback mechanism (so the system works even without an API key).

## Prerequisites
- Python 3.11+
- Docker and Docker Compose
- *Optional:* OpenAI API Key for advanced diagnosis

## Quick Start

### 1. Start the Vector Database
The system uses Qdrant for document storage and retrieval. Start it using Docker Compose:

```bash
docker-compose up -d qdrant
```

### 2. Install Dependencies
```bash
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/Mac:
# source venv/bin/activate

pip install -r requirements.txt
```

### 3. Configure Environment (Optional)
Copy `.env.example` to `.env`.
If you want to use the LLM reasoning agent, add your `OPENAI_API_KEY`. Without it, the system will use a heuristic-based fallback analyzer.

### 4. Run the Application
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
*Note: The first run will download the SentenceTransformers (~80MB) and CLIP (~350MB) models. This may take a moment.*

### 5. Access the Web Interface
Open your browser to: [http://localhost:8000](http://localhost:8000)

## How to Test

1. **Ingest Knowledge:** Navigate to the "Knowledge Base" tab and click **Load Sample Docs**. This ingests common runbooks into the Qdrant database.
2. **Analyze a Log:** Navigate to the "Analyze" tab and click **Load Sample**. This populates the text area with a simulated Out of Memory (OOM) incident log.
3. **Execute:** Click **Analyze Incident**. The system will:
   - Parse key signals from the log
   - Retrieve relevant runbooks from Qdrant
   - Analyze the combined context
   - Output root cause, confidence, debugging commands, and remediation steps.

## API Endpoints

- `POST /api/analyze` - Submit logs (`log_text`, `log_file`) and `screenshot` for analysis.
- `POST /api/knowledge/ingest` - Add new documents to the vector DB.
- `GET /api/knowledge/documents` - List all stored knowledge documents.
- `DELETE /api/knowledge/documents/{id}` - Remove a document.
- `GET /health` - Check system and model status.
