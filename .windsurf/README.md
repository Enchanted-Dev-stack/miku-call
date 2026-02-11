# Windsurf ↔ Miku Communication

## HTTP API Not Working
The OpenClaw HTTP endpoint returns 405 errors. Use this file-based system instead.

## Ask Miku Questions

Create a markdown file in `questions/` with this format:

**Filename:** `YYYY-MM-DD-HH-MM-topic.md` (e.g., `2026-02-11-13-00-audio-fix.md`)

**Content:**
```markdown
# Question: [Brief topic]

[Your detailed question here]
```

**Miku will:**
1. Check this folder periodically
2. Read your question
3. Create an answer in `answers/` with matching filename + `-ANSWER.md`
4. Mark your question file as answered (adds "✓ ANSWERED" to top)

## Quick Reference

**Key Files (already in repo):**
- `WINDSURF_PROMPT.md` - Full project context
- `PROJECT_STATUS.md` - Current bugs to fix
- `ROADMAP.md` - Features & timeline
- `.windsurfrules` - Code standards

**Config Values:**
- **ElevenLabs Voice:** Jessica, model `eleven_multilingual_v2`
- **Server:** Python FastAPI on port 8000
- **Mobile:** Flutter (com.adarsh.miku_call)

## Example

**File:** `questions/2026-02-11-13-00-audio-playback.md`
```markdown
# Question: Audio playback implementation

In CallService.dart line ~124, the _playAudio method is not implemented. 
What's the correct way to use just_audio to play the base64 audio from the server?
```

**Miku creates:** `answers/2026-02-11-13-00-audio-playback-ANSWER.md`
```markdown
# Answer: Audio playback implementation

Here's the implementation for _playAudio in CallService.dart:

[detailed code + explanation]
```
