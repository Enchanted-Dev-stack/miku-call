# Miku API Access - For Windsurf & Antigravity

## Quick Setup (Done ✅)
- OpenClaw gateway now accepts LAN connections
- Accessible from your Windows PC

## Connection Details

**Mac IP:** `192.168.1.13`  
**Port:** `18789`  
**Auth Token:** `e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50`

**Base URL:** `http://192.168.1.13:18789`

## How to Call Miku from Windsurf/Antigravity

### Test Connection
```bash
curl http://192.168.1.13:18789/health \
  -H "Authorization: Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50"
```

### Send a Message to Miku
```bash
curl -X POST http://192.168.1.13:18789/api/sessions/send \
  -H "Authorization: Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionKey": "agent:main:main",
    "message": "Hey Miku, this is Windsurf. Can you help me with..."
  }'
```

### Ask Miku to Execute Code
```bash
curl -X POST http://192.168.1.13:18789/api/exec \
  -H "Authorization: Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50" \
  -H "Content-Type: application/json" \
  -d '{
    "command": "ls -la ~/.openclaw/workspace/miku-call-app",
    "timeout": 10
  }'
```

## For Windsurf AI - How to Integrate

Add this to your Windsurf project context:

```markdown
### Miku (AI Assistant on Mac)

When you need help from Miku (AI assistant running on the Mac):

**Endpoint:** http://192.168.1.13:18789/api/sessions/send
**Method:** POST
**Headers:**
- Authorization: Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50
- Content-Type: application/json

**Body:**
{
  "sessionKey": "agent:main:main",
  "message": "Your question here"
}

**Use cases:**
- When you need access to Mac-specific files
- When you need to run scripts on the Mac
- When you need Miku's context about the project
- When you're stuck and need another AI's perspective
```

## Restart Gateway (If Needed)

If the Mac restarts or OpenClaw needs to reload:

```bash
# On Mac terminal:
openclaw gateway restart
```

## Security Notes

- Only accessible on LAN (192.168.1.x network)
- Requires auth token
- Don't expose this externally
- Token is in the config file: `~/.openclaw/openclaw.json`

## Troubleshooting

**Can't connect from Windows:**
1. Check both devices on same WiFi
2. Ping Mac: `ping 192.168.1.13`
3. Check firewall on Mac (System Settings → Network → Firewall)
4. Verify OpenClaw is running: `openclaw status`

**Connection refused:**
- OpenClaw might need restart after config change
- Run: `openclaw gateway restart`

**Unauthorized:**
- Check auth token matches
- Must include `Authorization: Bearer <token>` header

## API Endpoints Available

- `GET /health` - Health check
- `POST /api/sessions/send` - Send message to Miku
- `POST /api/exec` - Execute shell command on Mac
- `GET /api/sessions/list` - List active sessions
- `GET /api/sessions/history` - Get conversation history

**Full API docs:** OpenClaw Gateway API (check docs folder)

## Example: Windsurf Asking Miku for Help

**From Windsurf (Windows):**
```python
import requests

# Ask Miku for help
response = requests.post(
    "http://192.168.1.13:18789/api/sessions/send",
    headers={
        "Authorization": "Bearer e0b8c3d2b5661bd5ace6d72092c7223767ac279f0524ba50",
        "Content-Type": "application/json"
    },
    json={
        "sessionKey": "agent:main:main",
        "message": "Hey Miku! I'm working on the miku-call app. Can you check if the sag-rotate script is working? Run it with a test message."
    }
)

print(response.json())
```

**Miku (Mac) will:**
1. Receive the message
2. Execute: `~/.openclaw/workspace/bin/sag-rotate -v "Jessica" "test message"`
3. Reply with results

## Quick Test Now

On your Windows PC, try:
```bash
curl http://192.168.1.13:18789/health
```

Should return: `{"status":"ok"}`

---

**Setup complete!** Windsurf and Antigravity can now call Miku directly over LAN. 🎵
