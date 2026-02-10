#!/bin/bash
# Quick start script for Miku Call Server

echo "🎵 Starting Miku Call Server..."
echo ""

# Check if dependencies are installed
if ! python3 -c "import fastapi" 2>/dev/null; then
    echo "📦 Installing dependencies..."
    pip3 install -r requirements.txt --break-system-packages
fi

# Check for API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  Warning: ANTHROPIC_API_KEY not set"
    echo "   Set it in your environment or .env file"
    echo ""
fi

# Start server
echo "🚀 Server starting on http://0.0.0.0:8080"
echo ""
python3 main.py
