# Miku Call - Development Roadmap 🎵

## Phase 1: MVP (✅ Complete)
- [x] Server backend with WebSocket
- [x] Whisper STT integration
- [x] Claude conversation brain
- [x] Jessica TTS integration
- [x] Flutter app scaffold
- [x] Call screen UI
- [x] Audio recording
- [x] Basic WebSocket communication

**Time:** 20 minutes | **Status:** Done

---

## Phase 2: Make It Work (Current Priority)

### Critical Fixes (Must Do First)
1. **Audio Playback Fix** [HIGH PRIORITY]
   - Current: Just logs, doesn't play
   - Fix: Implement proper AudioSource for just_audio
   - Alternative: Save to temp file, then play
   - Estimated: 30 min

2. **Whisper Dependency Fix** [HIGH PRIORITY]
   - Current: Installation fails (pkg_resources error)
   - Options:
     - Fix setuptools: `pip3 install setuptools`
     - Use faster-whisper instead: `pip3 install faster-whisper`
     - Use Whisper API (costs money but simpler)
   - Estimated: 15 min

3. **Firebase Setup** [REQUIRED]
   - Get GoogleService-Info.plist
   - Place in ios/Runner/
   - Test push notifications
   - Estimated: 15 min

4. **Server URL Config** [MEDIUM]
   - Current: Hardcoded localhost
   - Make it configurable (environment variable or settings screen)
   - Support ngrok URL
   - Estimated: 10 min

### Testing & Debugging
5. **End-to-End Test**
   - Start server
   - Run app
   - Make test call
   - Verify audio flows both ways
   - Estimated: 30 min

**Phase 2 Total:** ~2 hours

---

## Phase 3: Production Ready

### Features
6. **Background Mode**
   - CallKit integration (iOS native call UI)
   - Background audio permissions
   - Keep WebSocket alive in background
   - Estimated: 1 hour

7. **Audio Quality**
   - Use Opus codec (smaller, better quality)
   - Add noise suppression
   - Echo cancellation
   - Estimated: 45 min

8. **Reconnection Logic**
   - Auto-reconnect if WebSocket drops
   - Handle network changes gracefully
   - Queue audio during reconnection
   - Estimated: 30 min

9. **Settings Screen**
   - Configure server URL
   - Audio quality settings
   - Notification preferences
   - Estimated: 30 min

10. **Call History**
    - Log past calls
    - Show duration, timestamp
    - Replay recordings (optional)
    - Estimated: 45 min

**Phase 3 Total:** ~4 hours

---

## Phase 4: Polish & Extras

11. **Android Support**
    - Port to Android
    - Use ConnectionService instead of CallKit
    - Test on multiple devices
    - Estimated: 2 hours

12. **UI Polish**
    - Animations
    - Better icons
    - Custom ringtone
    - Dark mode
    - Estimated: 1 hour

13. **Advanced Features**
    - Video calling (future)
    - Screen sharing (future)
    - Call recording
    - Multiple languages beyond Hindi/English
    - Estimated: 5+ hours

**Phase 4 Total:** ~8 hours

---

## Total Timeline

| Phase | Time | Status |
|-------|------|--------|
| Phase 1: MVP | 20 min | ✅ Done |
| Phase 2: Make It Work | 2 hours | 🔄 In Progress |
| Phase 3: Production | 4 hours | ⏳ Planned |
| Phase 4: Polish | 8 hours | ⏳ Future |

**To working app:** ~2 hours from now  
**To production-ready:** ~6 hours from now

---

## Current Blockers

### Immediate
- [ ] Audio playback not implemented
- [ ] Whisper installation failing
- [ ] No Firebase config

### Soon
- [ ] Server URL hardcoded
- [ ] No background mode

---

## Quick Wins (Do These First)

1. **Fix Whisper** (15 min)
   ```bash
   pip3 install faster-whisper --break-system-packages
   # Update whisper_stt.py to use faster-whisper
   ```

2. **Fix Audio Playback** (30 min)
   ```dart
   // In call_service.dart
   Future<void> _playAudio(Uint8List audioData) async {
     final tempFile = File('${Directory.systemTemp.path}/response.mp3');
     await tempFile.writeAsBytes(audioData);
     await _audioPlayer.setFilePath(tempFile.path);
     await _audioPlayer.play();
   }
   ```

3. **Add Firebase** (15 min)
   - Go to Firebase Console
   - Add iOS app
   - Download GoogleService-Info.plist
   - Done

**Total quick wins:** 1 hour to working MVP

---

## Testing Checklist

- [ ] Server starts without errors
- [ ] App connects to server
- [ ] Microphone records audio
- [ ] Server receives audio
- [ ] Whisper transcribes correctly
- [ ] Claude generates response
- [ ] Jessica synthesizes speech
- [ ] App receives audio response
- [ ] Audio plays through speaker
- [ ] User can hear Miku
- [ ] Full conversation works
- [ ] Call can be ended gracefully

---

## Success Criteria

**MVP Success:**
- Adarsh can receive a call from Miku
- Speak to Miku and hear responses
- End the call

**Production Success:**
- Calls work reliably (95%+ success rate)
- Low latency (<2 seconds for response)
- Jessica voice sounds good
- Works in background
- No crashes

**Long-term Success:**
- Used regularly for critical alerts
- Zero ongoing costs
- Easy to maintain
- Can add features easily

---

## Notes for Windsurf

- Start with Phase 2, Critical Fixes
- Test often (don't code too long without testing)
- Use existing infrastructure (sag-rotate, ElevenLabs keys)
- Keep it simple (don't over-engineer)
- Real-time matters more than perfection
- Adarsh has Windsurf subscription, so use it well
- Focus on making it WORK before making it PERFECT

---

**Next Session:** Fix audio playback + Whisper, then test end-to-end
