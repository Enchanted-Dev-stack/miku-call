"""
Miku Brain Module
Routes voice call messages to the main Miku agent via OpenClaw API
This ensures voice calls reach the SAME Miku with full memory & context
"""

import os
import requests

class MikuBrain:
    def __init__(self):
        """Initialize connection to OpenClaw API"""
        self.api_url = "http://localhost:18789/v1/chat/completions"
        self.auth_token = "e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50"
        
        # Voice call context prefix
        self.voice_context = "[VOICE CALL] Keep responses short (1-3 sentences) for real-time voice conversation. "
        
        print(f"🧠 Miku Brain initialized (routing to main agent)")
    
    async def generate_response(self, user_message: str, conversation_history: list = None) -> str:
        """
        Send message to main Miku agent (THIS session)
        
        Args:
            user_message: What the user just said
            conversation_history: Previous messages in the call (ignored - main session has full history)
        
        Returns:
            Miku's response text
        """
        try:
            # Prepend voice context to help with brevity
            message_with_context = f"{self.voice_context}{user_message}"
            
            # Call OpenClaw API (routes to agent:main)
            response = requests.post(
                self.api_url,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.auth_token}"
                },
                json={
                    "messages": [
                        {"role": "user", "content": message_with_context}
                    ],
                    "model": "openclaw:main",
                    "user": "voice-call"  # Separate user ID for voice context
                },
                timeout=30
            )
            
            response.raise_for_status()
            data = response.json()
            
            # Extract response text
            response_text = data["choices"][0]["message"]["content"]
            
            return response_text
        
        except Exception as e:
            print(f"❌ Miku API error: {e}")
            return "Sorry, I'm having trouble thinking right now. Can you repeat that?"


# Singleton instance
_miku_instance = None

def get_claude(model=None):  # Keep function name for compatibility
    """Get or create Miku instance (singleton)"""
    global _miku_instance
    if _miku_instance is None:
        _miku_instance = MikuBrain()
    return _miku_instance
