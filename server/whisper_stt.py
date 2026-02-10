"""
Whisper Speech-to-Text Module
Transcribes audio to text using OpenAI Whisper (local)
"""

import whisper
import tempfile
import os
from pathlib import Path

class WhisperSTT:
    def __init__(self, model_name="base"):
        """
        Initialize Whisper model
        Models: tiny, base, small, medium, large
        Larger = more accurate but slower
        """
        print(f"🎙️ Loading Whisper model: {model_name}")
        self.model = whisper.load_model(model_name)
        print(f"✅ Whisper {model_name} loaded")
    
    async def transcribe(self, audio_data: bytes) -> str:
        """
        Transcribe audio bytes to text
        
        Args:
            audio_data: Raw audio bytes (WAV, MP3, etc.)
        
        Returns:
            Transcribed text
        """
        try:
            # Save audio to temp file (Whisper needs file input)
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_audio:
                temp_audio.write(audio_data)
                temp_path = temp_audio.name
            
            # Transcribe
            result = self.model.transcribe(temp_path, language="en")
            text = result["text"].strip()
            
            # Cleanup
            os.unlink(temp_path)
            
            return text
        
        except Exception as e:
            print(f"❌ Whisper transcription error: {e}")
            return ""


# Singleton instance
_whisper_instance = None

def get_whisper(model_name="base"):
    """Get or create Whisper instance (singleton)"""
    global _whisper_instance
    if _whisper_instance is None:
        _whisper_instance = WhisperSTT(model_name)
    return _whisper_instance
