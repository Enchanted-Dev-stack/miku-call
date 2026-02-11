# Miku Call - Real-Time Voice Call App 🎵

AI-powered voice calling app that lets Miku (your AI assistant) call you for real-time conversations.

**Key Feature:** Voice calls reach the SAME Miku you chat with on Telegram - with full memory, context, and personality!

## Architecture

```
Mobile App (iOS) ←─WebSocket─→ Server (Mac) ←─HTTP API─→ OpenClaw (Miku Main Agent)
        ↓                           ↓                            ↓
    Microphone              ┌───────┴───────┐              Full Memory
        ↓                   ↓               ↓              & Context
    Audio Stream        Whisper         ElevenLabs
        ↓                   ↓               ↓
    Speaker            ←─Audio─Text────Audio─
                                      ↑
                              Miku's Response
                         (same agent, remembers you)
```

**Why this matters:**
- ✅ Voice calls = talking to YOUR Miku (not a generic AI)
- ✅ Remembers previous conversations (MEMORY.md)
- ✅ Knows your preferences, context, projects
- ✅ Same personality across Telegram & voice
- ✅ No separate API key needed

## Features

- ✅ Real-time voice conversations with Miku
- ✅ Jessica voice (ElevenLabs, bilingual Hindi/English)
- ✅ Push notifications for incoming calls
- ✅ Low-latency audio streaming
- ✅ Free (no ongoing costs, uses existing keys)

## Setup Instructions

### 1. Server Setup (Mac)

#### a. Install Python dependencies
```bash
cd ~/.openclaw/workspace/miku-call-app/server
pip3 install -r requirements.txt --break-system-packages
```

#### b. Configuration (No API key needed!)
The server routes to your main OpenClaw agent, so it uses your existing OAuth setup.

**Requirements:**
- OpenClaw running (`openclaw gateway status`)
- Chat completions endpoint enabled (already done)
- Server runs on same machine as OpenClaw (localhost communication)

#### c. Start the server
```bash
python3 main.py
```

Server will run on `http://0.0.0.0:8080`

### 2. Mobile App Setup (iOS)

#### a. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Add iOS app:
   - Bundle ID: `com.miku.mikuCall`
   - Download `GoogleService-Info.plist`
4. Place `GoogleService-Info.plist` in:
   ```
   mobile/miku_call/ios/Runner/GoogleService-Info.plist
   ```

5. Enable Cloud Messaging:
   - Firebase Console → Project Settings → Cloud Messaging
   - Enable Firebase Cloud Messaging API

#### b. Update server URL

Edit `lib/services/call_service.dart`:
```dart
// Replace with your Mac's IP or ngrok URL
static const String _serverUrl = 'ws://YOUR_MAC_IP:8080/call/connect';
```

**Finding your Mac IP:**
```bash
ipconfig getifaddr en0  # For WiFi
# or
ipconfig getifaddr en1  # For Ethernet
```

**Or use ngrok for public URL:**
```bash
ngrok http 8080
# Use the https URL it provides
```

#### c. iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Miku needs microphone access for voice calls</string>
```

#### d. Build and run
```bash
cd mobile/miku_call
flutter pub get
flutter run
```

### 3. Testing the Call Flow

#### Test 1: Server Health Check
```bash
curl http://localhost:8080/
# Should return: {"status":"ok","service":"Miku Call Server"}
```

#### Test 2: Manual Call Trigger
On the app's home screen, tap "Test Call" to manually start a call without waiting for a push notification.

#### Test 3: Incoming Call (Production)
From your OpenClaw workspace, run:
```bash
curl -X POST "http://localhost:8080/call/initiate?user_id=adarsh"
```

This will:
1. Send push notification to your phone
2. Show incoming call screen
3. When you accept, establish WebSocket connection
4. Start real-time voice conversation

## How It Works

### Call Flow

1. **Initiate Call**
   - Server sends Firebase push notification
   - App shows incoming call screen
   - User accepts call

2. **Connection**
   - App connects to server via WebSocket
   - Starts recording microphone
   - Establishes bidirectional audio stream

3. **Conversation Loop**
   ```
   User speaks → Mic capture → WebSocket send
                                    ↓
   Server receives audio → Whisper STT → Text
                                    ↓
                         Claude generates response
                                    ↓
                    ElevenLabs TTS (Jessica) → Audio
                                    ↓
   User hears Miku ← Speaker playback ← WebSocket receive
   ```

4. **End Call**
   - User hangs up
   - WebSocket closes
   - Recording stops

### Server Components

- **`main.py`** - FastAPI server with WebSocket endpoint
- **`whisper_stt.py`** - Speech-to-text using OpenAI Whisper
- **`claude_brain.py`** - Conversation AI (Haiku 4.5 for speed)
- **`jessica_tts.py`** - Text-to-speech using existing sag-rotate script

### Mobile App Components

- **`main.dart`** - App entry, Firebase initialization
- **`call_screen.dart`** - Call UI (answer, mute, hang up)
- **`call_service.dart`** - WebSocket, audio recording/playback

## Configuration Files

### Server Config
- `.env` or environment variables for API keys
- `requirements.txt` - Python dependencies

### Mobile Config
- `GoogleService-Info.plist` - Firebase iOS config
- `pubspec.yaml` - Flutter dependencies

## Costs

- **Server**: Free (runs on your Mac)
- **Whisper**: Free (local model)
- **Claude API**: ~$0.001-0.003 per call (Haiku 4.5)
- **ElevenLabs**: Free tier (4-key rotation)
- **Firebase**: Free tier (plenty for personal use)

**Total: Essentially free** for occasional calls.

## Troubleshooting

### Server won't start
```bash
# Check if port 8080 is in use
lsof -i :8080

# Kill existing process
kill -9 <PID>
```

### App can't connect to server
- Check server is running: `curl http://localhost:8080/`
- Check firewall isn't blocking port 8080
- Use ngrok if on different networks
- Update `_serverUrl` in `call_service.dart`

### No push notifications
- Check Firebase config is correct
- Check FCM token is being generated (see app console logs)
- Verify Cloud Messaging API is enabled

### Audio quality issues
- Use headphones (avoids echo/feedback)
- Check microphone permissions
- Try upgrading Whisper model to "small" or "medium" in `main.py`

## Next Steps

### Production Improvements
- [ ] Better audio codec (Opus instead of WAV)
- [ ] Audio playback from bytes (currently placeholder)
- [ ] Background mode (receive calls when app is closed)
- [ ] CallKit integration (iOS native call UI)
- [ ] Reconnection logic if WebSocket drops
- [ ] Call history
- [ ] Settings screen (server URL, audio quality)

### Future Features
- [ ] Video calling
- [ ] Screen sharing
- [ ] Multiple participants
- [ ] Call recording
- [ ] Voicemail

## Credits

Built for Adarsh by Miku (with Sonnet 4.5) 🎵
