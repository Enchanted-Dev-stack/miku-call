# Windsurf Starting Prompt

Copy-paste this entire prompt to Windsurf AI:

---

Hi! I need you to help me complete a real-time voice calling app called **Miku Call**. This is an AI-powered app that lets my AI assistant (Miku) call me on my phone for voice conversations.

## Context

**What is this?**
A Flutter iOS app + Python backend that enables real-time voice conversations between me (Adarsh) and Miku (AI assistant with Jessica's voice - bilingual Hindi/English).

**Current Status:**
- MVP is 80% complete (built in 20 minutes by Claude Sonnet 4.5)
- Server backend works (Python + FastAPI + WebSocket)
- Flutter app scaffold is done
- AI pipeline integrated (Whisper STT → Claude Haiku 4.5 → ElevenLabs TTS)
- But there are 3 critical bugs preventing it from working

**Tech Stack:**
- Backend: Python, FastAPI, WebSocket, OpenAI Whisper, Claude API, ElevenLabs
- Frontend: Flutter (iOS only for now)
- Infrastructure: Firebase (push notifications), ngrok (tunneling)

## Your Tasks

### Step 1: Get the Code
```bash
# Clone the repository
git clone https://github.com/Enchanted-Dev-stack/miku-call.git
cd miku-call

# Read these files first (in this order):
# 1. README.md - Full setup guide
# 2. ROADMAP.md - Development priorities
# 3. PROJECT_STATUS.md - Current state and TODOs
# 4. .windsurfrules - Project context and guidelines
```

### Step 2: Fix Critical Issues (Priority Order)

**Issue 1: Audio Playback Not Working** [CRITICAL]
- **File:** `mobile/miku_call/lib/services/call_service.dart`
- **Problem:** The `_playAudio()` method just logs, doesn't actually play audio
- **Fix:** Implement proper audio playback using just_audio
- **Solution:**
  ```dart
  Future<void> _playAudio(Uint8List audioData) async {
    try {
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/response_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioData);
      
      // Play using just_audio
      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
      
      // Clean up after playing
      _audioPlayer.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          tempFile.delete();
        }
      });
    } catch (e) {
      print('Audio playback error: $e');
    }
  }
  ```
- **Estimated Time:** 30 minutes

**Issue 2: Whisper Dependency Installation Failed** [CRITICAL]
- **File:** `server/whisper_stt.py`
- **Problem:** `openai-whisper` won't install (pkg_resources error)
- **Fix:** Use `faster-whisper` instead (it's faster and easier to install)
- **Steps:**
  1. Update `server/requirements.txt`: Replace `openai-whisper==20231117` with `faster-whisper==1.1.0`
  2. Update `server/whisper_stt.py` to use faster-whisper:
     ```python
     from faster_whisper import WhisperModel
     
     class WhisperSTT:
         def __init__(self, model_name="base"):
             print(f"🎙️ Loading Faster Whisper model: {model_name}")
             self.model = WhisperModel(model_name, device="cpu", compute_type="int8")
             print(f"✅ Faster Whisper {model_name} loaded")
         
         async def transcribe(self, audio_data: bytes) -> str:
             # (same temp file logic as before)
             segments, info = self.model.transcribe(temp_path, language="en")
             text = " ".join([segment.text for segment in segments]).strip()
             return text
     ```
  3. Install: `pip3 install -r server/requirements.txt --break-system-packages`
- **Estimated Time:** 20 minutes

**Issue 3: Firebase Configuration Missing** [REQUIRED]
- **Problem:** No `GoogleService-Info.plist` in the iOS project
- **What I need to provide:** I'll give you the Firebase config file
- **Where to place it:** `mobile/miku_call/ios/Runner/GoogleService-Info.plist`
- **For now:** Skip this, we'll test without push notifications first (use "Test Call" button)
- **Estimated Time:** 5 minutes (when I provide the file)

### Step 3: Test End-to-End

**Server Test:**
```bash
cd server
pip3 install -r requirements.txt --break-system-packages
export ANTHROPIC_API_KEY="<will-provide>"
python3 main.py
```

Expected output: `Server starting on http://0.0.0.0:8080`

**Health Check:**
```bash
curl http://localhost:8080/
```

Expected: `{"status":"ok","service":"Miku Call Server"}`

**App Test:**
```bash
cd mobile/miku_call
flutter pub get
flutter run
```

**In the app:**
1. Tap "Test Call"
2. Accept microphone permission
3. Speak: "Hello Miku, can you hear me?"
4. Wait for response audio

**Expected Flow:**
- App shows "Connected"
- Audio records from mic
- Sends to server via WebSocket
- Server transcribes → generates response → synthesizes speech
- App receives audio → plays through speaker
- You hear Miku (Jessica voice) responding

### Step 4: Additional Fixes (If Time Permits)

**Fix 4: Make Server URL Configurable**
- Currently hardcoded to `localhost:8080`
- Allow changing it (for ngrok, different network, etc.)
- Add settings screen or use environment variable

**Fix 5: Better Error Handling**
- Add try-catch around WebSocket operations
- Show user-friendly error messages
- Auto-reconnect if connection drops

## Important Notes

**API Keys I'll Provide:**
- `ANTHROPIC_API_KEY` - For Claude API
- ElevenLabs keys are already configured (via sag-rotate script at `~/.openclaw/workspace/bin/sag-rotate`)

**Testing Notes:**
- Use a real iOS device if possible (simulator audio is unreliable)
- Wear headphones to avoid echo/feedback
- Server must be running before starting the app
- Keep server terminal visible to see logs

**Cost Concerns:**
- I'm cost-conscious, keep API calls minimal during testing
- Use Haiku 4.5 (not Opus) for Claude - it's faster and cheaper
- ElevenLabs: Already has 4-key rotation, plenty of free credits

**Code Style:**
- Follow existing patterns in the codebase
- Keep it simple (real-time matters more than perfection)
- Comment only when necessary
- Log everything (helps debugging)

## Success Criteria

**Minimum Success:**
- Server starts without errors
- App connects to server via WebSocket
- I can speak and hear Miku respond with Jessica's voice
- Call can be ended cleanly

**Full Success:**
- Audio quality is good (clear, no distortion)
- Latency is low (<2 seconds for response)
- No crashes during call
- Conversation flows naturally

## Questions You Might Have

**Q: Where's the sag-rotate script?**
A: It's at `~/.openclaw/workspace/bin/sag-rotate` - already configured with 4 ElevenLabs keys

**Q: What if I can't test on iOS?**
A: Fix the code issues, then I'll test on my iPhone and report back

**Q: Should I add new features?**
A: No, just fix the 3 critical bugs first. Get it working, then we can enhance.

**Q: Can I refactor the code?**
A: Only if absolutely necessary. Prefer fixing bugs over refactoring.

## Documentation Reference

All documentation is in the repo:
- `README.md` - Comprehensive setup guide
- `ROADMAP.md` - Development timeline and priorities
- `PROJECT_STATUS.md` - Current state, known issues
- `.windsurfrules` - Detailed project context

## Final Notes

This project was built in 20 minutes as an MVP. It's 80% there - just needs those 3 bugs fixed to be fully working. 

Focus on making it WORK first, then we can make it PERFECT.

The goal: I should be able to receive a call from Miku, have a voice conversation in real-time, and hear her Jessica voice (bilingual Hindi/English).

Good luck! Let me know if you need any clarification or run into issues.

---

**Expected Total Time:** 1-2 hours to working app
**Your Focus:** Fix bugs 1 & 2, test end-to-end
**My Part:** Provide API keys and Firebase config when needed
