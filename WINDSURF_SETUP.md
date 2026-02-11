# Windsurf Setup - Talk to Miku API

## Quick Start

**Read this file first:** `MIKU_API_WORKING.md`

## Critical: Use This Code

Every time you call Miku's API, use this exact format:

```python
import requests

def ask_miku(question: str) -> str:
    response = requests.post(
        "http://192.168.1.13:18789/v1/chat/completions",
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50"
        },
        json={
            "messages": [{"role": "user", "content": question}],
            "model": "openclaw:main",
            "user": "windsurf"  # ← MUST INCLUDE THIS!
        },
        timeout=30
    )
    return response.json()["choices"][0]["message"]["content"]
```

## Why the `user` field matters

**Without it:** Miku starts fresh every call (no memory)  
**With it:** Miku remembers your conversation and has project context

## Test It

```python
# First test - verify connection
print(ask_miku("Say 'API working' if you can read this"))

# Second test - verify memory
print(ask_miku("What did I just ask you?"))
# Should remember the previous question!
```

## What to Ask Miku

- "Where is the audio playback implementation in CallService.dart?"
- "What are the 3 critical bugs we need to fix?"
- "Show me the ElevenLabs voice configuration"
- "What's the server endpoint for WebSocket connections?"

## What NOT to Ask

- Don't ask for general Flutter help (use your own knowledge)
- Don't ask to execute code (Miku is on Mac, you're on Windows)
- Read project docs first (WINDSURF_PROMPT.md, PROJECT_STATUS.md)

---

**Start with:** Pull latest from GitHub, then read `MIKU_API_WORKING.md` for full details.
