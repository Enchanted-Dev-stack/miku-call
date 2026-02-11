# Miku API - CONFIRMED WORKING ✅

**Tested:** 2026-02-11 13:10 IST  
**Status:** Both localhost and LAN access working

---

## Connection Details

- **URL:** `http://192.168.1.13:18789/v1/chat/completions`
- **Auth:** `Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50`
- **Model:** `openclaw:main` (use this in the model field)

---

## Python Example (Tested & Working)

```python
import requests

def ask_miku(question: str) -> str:
    """Ask Miku a question via OpenClaw API"""
    
    response = requests.post(
        "http://192.168.1.13:18789/v1/chat/completions",
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50"
        },
        json={
            "messages": [
                {"role": "user", "content": question}
            ],
            "model": "openclaw:main"
        },
        timeout=30
    )
    
    response.raise_for_status()
    data = response.json()
    return data["choices"][0]["message"]["content"]

# Example usage
if __name__ == "__main__":
    answer = ask_miku("Where is the audio playback logic in CallService.dart?")
    print(answer)
```

---

## PowerShell Test (Windows)

```powershell
curl.exe -X POST http://192.168.1.13:18789/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50" -d "{\"messages\":[{\"role\":\"user\",\"content\":\"Hello Miku\"}],\"model\":\"openclaw:main\"}"
```

---

## What You Can Ask

**Project Questions:**
- "Where is the WebSocket connection implemented in the mobile app?"
- "What's the correct ElevenLabs voice configuration?"
- "Show me the audio playback implementation we need to fix"
- "What are the 3 critical bugs in PROJECT_STATUS.md?"

**File Locations:**
- "What's in WINDSURF_PROMPT.md?"
- "Show me the FastAPI server structure"
- "Where are the Whisper STT dependencies?"

**Configuration:**
- "What's the ElevenLabs API key rotation setup?"
- "What port does the server run on?"
- "What's the Firebase config we're missing?"

---

## Notes

- Responses may take 5-10 seconds (Claude Sonnet 4.5 processing)
- Miku has full context of the miku-call-app project
- All files in `~/.openclaw/workspace/` are accessible
- Memory includes all decisions, preferences, and technical details from previous conversations
