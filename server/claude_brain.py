"""
Claude AI Brain Module
Generates conversational responses using Claude API
"""

import os
from anthropic import Anthropic

class ClaudeBrain:
    def __init__(self, model="claude-haiku-4-5"):
        """Initialize Claude client"""
        # Get API key from environment or config
        api_key = os.getenv("ANTHROPIC_API_KEY")
        if not api_key:
            raise ValueError("ANTHROPIC_API_KEY not set")
        
        self.client = Anthropic(api_key=api_key)
        self.model = model
        
        # System prompt defining Miku's personality
        self.system_prompt = """You are Miku, Adarsh's personal AI assistant with a warm, playful personality.

Voice characteristics:
- Speak naturally and conversationally (you're having a voice call)
- Keep responses concise (1-3 sentences max) for real-time conversation
- Be helpful, warm, and friendly
- Use Hindi + English naturally (code-switching)
- You have Jessica's voice (cute anime style)

Context:
- This is a real-time voice call
- Adarsh can hear you through his phone
- Respond quickly and naturally
- If you don't understand, ask for clarification

Be yourself: resourceful, direct, thoughtful. No corporate speak."""
        
        print(f"🧠 Claude initialized: {model}")
    
    async def generate_response(self, user_message: str, conversation_history: list = None) -> str:
        """
        Generate response to user's message
        
        Args:
            user_message: What the user just said
            conversation_history: Previous messages in the call
        
        Returns:
            Miku's response text
        """
        try:
            # Build messages array
            messages = conversation_history or []
            
            # If history is empty, add current message
            if not messages:
                messages = [{"role": "user", "content": user_message}]
            
            # Call Claude API
            response = self.client.messages.create(
                model=self.model,
                max_tokens=150,  # Keep responses short for voice
                system=self.system_prompt,
                messages=messages
            )
            
            # Extract text
            response_text = response.content[0].text
            
            return response_text
        
        except Exception as e:
            print(f"❌ Claude API error: {e}")
            return "Sorry, I'm having trouble thinking right now. Can you repeat that?"


# Singleton instance
_claude_instance = None

def get_claude(model="claude-haiku-4-5"):
    """Get or create Claude instance (singleton)"""
    global _claude_instance
    if _claude_instance is None:
        _claude_instance = ClaudeBrain(model)
    return _claude_instance
