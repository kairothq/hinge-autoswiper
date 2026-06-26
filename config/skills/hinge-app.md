---
app: Hinge
archetype: feed
obstacle_mode: auto
---

## Structure
Hinge shows ONE profile at a time as a vertically scrolling card: a stack of
photos interleaved with prompt-answer cards and basic info (name, age, height,
location, job, etc.). You scroll down through a profile, then act on it.

## How liking / passing works (IMPORTANT)
- Each photo and each prompt card has a small circular **heart (Like)** button,
  usually in the lower-right corner of that card.
- Tapping a heart opens a "Send Like" sheet with an optional comment field and a
  **"Send Like"** button. For high-volume mode: tap heart, then tap **Send Like**
  WITHOUT typing a comment. This sends the like and loads the next profile.
- To **pass/skip**: tap the circular **X** button (bottom of the profile, or a
  floating X). The next profile loads.
- There is NO Tinder-style full-screen left/right swipe. Acting = tapping the
  heart or the X. Scrolling is only to read the profile.

## Tabs (bottom bar)
- Likes You (heart), Discover/Standouts (star), Matches (chat), Profile.
- The main swiping feed is the default home view (heart/flame icon, left).

## Obstacles (auto-dismiss)
- "Turn on notifications?" -> tap "Not Now" / "Maybe Later".
- "Add to Home Screen" / rating prompt -> dismiss / "Not Now".
- Location permission -> tap "Allow Once" only if it blocks the feed; otherwise dismiss.
- "Out of likes" / "You're out of free likes" / upgrade paywall -> STOP the run
  (do not purchase). Report back that the daily like limit was reached.
- "Roses" upsell sheet -> close it (X), never send a Rose.

## Skip / never touch
- Settings, account, subscription, payment, "Boost", "Roses", Rose purchase,
  any "Upgrade to Hinge+ / HingeX" button.

## Tips
- After Send Like or X, wait ~1s for the next profile to render before reading.
- If the screen looks identical after an action, the action may have missed;
  re-read the screen and retry once.

## Tap coordinates (IMPORTANT)
Coordinates are in WINDOW POINTS (~322x718), NOT screenshot pixels (the image is ~2x).
Always take tap points from describe_screen (it returns exact points). For icons not in
OCR (heart/X/search), estimate from the screenshot by dividing pixel coords by ~2.
The Like heart and pass X are icons — locate them relative to nearby OCR text.
