#!/usr/bin/env python3
"""
Miku Call Server - Real-time voice conversation backend
Handles WebSocket connections, STT, LLM, and TTS pipeline
"""

import asyncio
import json
import os
import sys
import base64
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
import uvicorn

# Add workspace bin to path for sag-rotate
sys.path.insert(0, str(Path.home() / ".openclaw" / "workspace" / "bin"))

app = FastAPI(title="Miku Call Server")

# Active call sessions
active_calls = {}

# Configuration
WHISPER_MODEL = "base"  # Can upgrade to "small" or "medium" for better accuracy
CLAUDE_MODEL = "anthropic/claude-haiku-4-5"
FIREBASE_CONFIG_PATH = Path.home() / ".openclaw" / "workspace" / ".firebase-config.json"


class CallSession:
    """Represents an active voice call session"""
    
    def __init__(self, websocket: WebSocket, user_id: str):
        self.websocket = websocket
        self.user_id = user_id
        self.is_active = True
        self.conversation_history = []
    
    async def process_audio(self, audio_data: bytes):
        """Process incoming audio: STT -> LLM -> TTS -> send back"""
        try:
            # Step 1: Speech-to-Text (Whisper)
            text = await self.transcribe_audio(audio_data)
            if not text:
                return
            
            print(f"📝 User said: {text}")
            self.conversation_history.append({"role": "user", "content": text})
            
            # Step 2: Generate response (Claude)
            response_text = await self.generate_response(text)
            print(f"💬 Miku responds: {response_text}")
            self.conversation_history.append({"role": "assistant", "content": response_text})
            
            # Step 3: Text-to-Speech (ElevenLabs Jessica)
            audio_response = await self.synthesize_speech(response_text)
            
            # Step 4: Send audio back to client
            if self.is_active:
                await self.websocket.send_json({
                    "type": "audio",
                    "data": base64.b64encode(audio_response).decode('utf-8')
                })
            
        except Exception as e:
            print(f"❌ Error processing audio: {e}")
            if self.is_active:
                try:
                    await self.websocket.send_json({
                        "type": "error",
                        "message": str(e)
                    })
                except Exception:
                    pass
    
    async def transcribe_audio(self, audio_data: bytes) -> Optional[str]:
        """Transcribe audio using Whisper"""
        from whisper_stt import get_whisper
        whisper = get_whisper()
        return await whisper.transcribe(audio_data)
    
    async def generate_response(self, user_text: str) -> str:
        """Generate AI response using Claude"""
        from claude_brain import get_claude
        claude = get_claude()
        return await claude.generate_response(user_text, self.conversation_history)
    
    async def synthesize_speech(self, text: str) -> bytes:
        """Synthesize speech using ElevenLabs Jessica voice"""
        from jessica_tts import get_jessica
        jessica = get_jessica()
        return await jessica.synthesize(text)


@app.get("/")
async def root():
    """Health check endpoint"""
    return {"status": "ok", "service": "Miku Call Server", "version": "1.0.0"}


@app.post("/call/initiate")
async def initiate_call(user_id: str):
    """Initiate a call to user via Firebase push notification"""
    try:
        # TODO: Send Firebase push notification
        # Trigger "incoming call" on user's phone
        return {"status": "ok", "message": f"Call initiated to {user_id}"}
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )


@app.websocket("/call/connect")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time voice call"""
    await websocket.accept()
    
    # Get user ID from query params or auth token
    user_id = "adarsh"  # TODO: Get from auth
    
    # Create call session
    session = CallSession(websocket, user_id)
    active_calls[user_id] = session
    
    print(f"📞 Call connected: {user_id}")
    
    try:
        await websocket.send_json({
            "type": "connected",
            "message": "Call connected. Start speaking!"
        })
        
        while session.is_active:
            # Receive audio data from client
            message = await websocket.receive_json()
            
            if message["type"] == "audio":
                # Decode base64 audio
                audio_data = base64.b64decode(message["data"])
                await session.process_audio(audio_data)
            
            elif message["type"] == "end_call":
                session.is_active = False
                break
    
    except WebSocketDisconnect:
        print(f"📴 Call disconnected: {user_id}")
    
    except Exception as e:
        print(f"❌ WebSocket error: {e}")
    
    finally:
        # Clean up
        session.is_active = False
        if user_id in active_calls:
            del active_calls[user_id]
        try:
            await websocket.close()
        except Exception:
            pass


if __name__ == "__main__":
    print("🎵 Starting Miku Call Server...")
    print(f"   Model: {CLAUDE_MODEL}")
    print(f"   Whisper: {WHISPER_MODEL}")
    print(f"   Voice: Jessica (ElevenLabs)")
    print()
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
