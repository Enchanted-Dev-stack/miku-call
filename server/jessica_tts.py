"""
Jessica TTS Module
Text-to-Speech using ElevenLabs Jessica voice via sag-rotate
"""

import subprocess
import tempfile
import os
from pathlib import Path

class JessicaTTS:
    def __init__(self):
        """Initialize Jessica TTS using existing sag-rotate script"""
        self.sag_rotate_path = Path.home() / ".openclaw" / "workspace" / "bin" / "sag-rotate"
        
        if not self.sag_rotate_path.exists():
            raise FileNotFoundError(f"sag-rotate not found at {self.sag_rotate_path}")
        
        print("🎵 Jessica TTS initialized (sag-rotate)")
    
    async def synthesize(self, text: str) -> bytes:
        """
        Convert text to speech using Jessica voice
        
        Args:
            text: Text to speak
        
        Returns:
            MP3 audio bytes
        """
        try:
            # Create temp file for output
            with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as temp_audio:
                temp_path = temp_audio.name
            
            # Call sag-rotate
            cmd = [
                str(self.sag_rotate_path),
                "-v", "Jessica",
                "--model-id", "eleven_multilingual_v2",
                "-o", temp_path,
                text
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                timeout=30
            )
            
            if result.returncode != 0:
                print(f"❌ sag-rotate error: {result.stderr.decode()}")
                return b""
            
            # Read the generated audio
            with open(temp_path, "rb") as f:
                audio_data = f.read()
            
            # Cleanup
            os.unlink(temp_path)
            
            return audio_data
        
        except Exception as e:
            print(f"❌ TTS error: {e}")
            return b""


# Singleton instance
_jessica_instance = None

def get_jessica():
    """Get or create Jessica TTS instance (singleton)"""
    global _jessica_instance
    if _jessica_instance is None:
        _jessica_instance = JessicaTTS()
    return _jessica_instance
