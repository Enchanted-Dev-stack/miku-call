# Miku API - CONFIRMED WORKING ✅

**Tested:** 2026-02-11 13:24 IST  
**Status:** Both localhost and LAN access working

---

## 📋 Instructions for Windsurf

**You are Windsurf (AI coding assistant on Windows PC).** Use this API to ask Miku (OpenClaw AI on Mac) questions about the miku-call-app project.

**Requirements:**
1. ✅ Always include `"user": "windsurf"` in every API request (creates persistent session)
2. ✅ Use `"model": "openclaw:main"` (not a real OpenAI model)
3. ✅ Include auth header with the bearer token below
4. ✅ Expect 5-10 second response time (Claude Sonnet 4.5 processing)

**What Miku knows:**
- Full miku-call-app codebase at `~/.openclaw/workspace/miku-call-app/`
- All project docs (WINDSURF_PROMPT.md, PROJECT_STATUS.md, ROADMAP.md)
- Configuration (API keys, server setup, voice settings)
- Past decisions and technical context from memory

**When to ask Miku:**
- Need file locations or code snippets from the project
- Clarification on design decisions or requirements
- Configuration values (ports, API keys, model IDs)
- Debugging help with the 3 critical bugs

**When NOT to ask Miku:**
- Info already in project docs (read those first)
- General Flutter/Python questions (use your own knowledge)
- Tasks you can do yourself (Miku is for context, not execution)

---

## Connection Details

- **URL:** `http://192.168.1.13:18789/v1/chat/completions`
- **Auth:** `Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50`
- **Model:** `openclaw:main` (use this in the model field)
- **User:** `windsurf` (REQUIRED for persistent session with memory)

---

## Python Example (REQUIRED FORMAT)

```python
import requests

def ask_miku(question: str) -> str:
    """
    Ask Miku a question via OpenClaw API
    
    IMPORTANT: Always include "user": "windsurf" for persistent session!
    Without it, Miku starts fresh each time with no memory.
    """
    
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
            "model": "openclaw:main",
            "user": "windsurf"  # ← REQUIRED! Creates persistent session
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

## 🚨 CRITICAL: The `user` Field

**Without `user` field:**
- Each API call = fresh Miku with zero memory
- No context from previous questions
- Wastes tokens repeating setup each time

**With `"user": "windsurf"`:**
- ✅ Creates persistent session across all Windsurf requests
- ✅ Miku remembers your conversation history
- ✅ Loads workspace context (AGENTS.md, TOOLS.md, project files)
- ✅ Can use memory_search to recall past work
- ✅ Faster responses (doesn't reload context each time)

**Example comparison:**

❌ **Bad (no user field):**
```python
# First call
ask_miku("Where's the repo?") → "I don't know"
# Second call
ask_miku("What did I just ask?") → "I have no context"
```

✅ **Good (with user field):**
```python
# First call with user="windsurf"
ask_miku("Where's the repo?") → "~/.openclaw/workspace/miku-call-app/"
# Second call with user="windsurf"
ask_miku("What did I just ask?") → "You asked about the repo location"
```

**ALWAYS include `"user": "windsurf"` in every request!**

---

## PowerShell Test (Windows)

```powershell
curl.exe -X POST http://192.168.1.13:18789/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50" -d "{\"messages\":[{\"role\":\"user\",\"content\":\"Hello Miku\"}],\"model\":\"openclaw:main\",\"user\":\"windsurf\"}"
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
