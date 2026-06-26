# hinge-autoswiper

An AI agent that auto-likes Hinge profiles on a **real iPhone**, driven by a local
(free) Gemma model or a cheap cloud model. No jailbreak, no fake API, no stored
passwords, it controls your actual phone through macOS iPhone Mirroring.

```
  Ollama / Gemma          Goose (agent loop)            mirroir-mcp            your iPhone
  (the brain)   <----->   sees screen, decides   <--->  taps/swipes/types  -->  (mirrored)
```

- **Brain:** any LLM via [Goose](https://block.github.io/goose/), local `ollama` (Gemma) or cloud (`openai`/`anthropic`/`google`).
- **Hands & eyes:** [mirroir-mcp](https://github.com/jfarcand/iphone-mirroir-mcp) captures the mirrored screen (OCR + vision) and sends real taps.
- **Logic:** a shareable Goose **recipe** with modes, warmup taste-calibration, and cautious pacing.

## Requirements
- macOS **15+** (Sequoia), iPhone Mirroring is macOS-only.
- An iPhone that supports iPhone Mirroring, signed into the same Apple ID.
- Homebrew + Node.js.
- For local Gemma: RAM matters. **8GB → `gemma3:4b`** (slow but works), **16GB → `gemma3:12b`**, **32GB+ → `gemma3:27b`**. Bigger = better judgment and more reliable tool-calling.
- For cloud: an API key for your provider (much lighter on your machine).

## Install
```bash
cp .env.example .env      # then edit: pick GOOSE_PROVIDER + GOOSE_MODEL
./install.sh
```
The installer sets up mirroir, Goose, and your chosen brain (pulls the Ollama model if local), and writes all config.

## Use
1. Open the **iPhone Mirroring** app, unlock the phone, keep the window **live (not paused)**.
2. On the first screenshot, approve the macOS **Screen Recording + Accessibility** prompts.
3. Smoke-test the control loop on YouTube (zero risk):
   ```bash
   ./run.sh test
   ```
4. When that works, open **Hinge** on the main feed and run the swiper:
   ```bash
   ./run.sh
   ```

## Configure (`.env`)
| Var | What |
|-----|------|
| `GOOSE_PROVIDER` | `ollama` (local) or `openai`/`anthropic`/`google` (cloud) |
| `GOOSE_MODEL` | e.g. `gemma3:4b`, `gpt-4o-mini`, `claude-haiku-4-5`, `gemini-2.0-flash` |
| `MODE` | `like_only` / `like_with_comment` / `full_access` |
| `SESSION_CAP` | profiles per session (default 40) |
| `MIN_DELAY` / `MAX_DELAY` | human-like seconds between actions |
| `WARMUP` | `true` = ask your taste on the first 5 profiles, then auto-run |
| `DEALBREAKERS` | comma-separated hard passes, or `none` |

## Safety
- Mutating tools are opt-in (`config/permissions.json`); Wallet/Messages/Mail/Photos/Banking are hard-blocked.
- **Kill switch:** close the iPhone Mirroring window to stop all input instantly.
- Keep your terminal's permission prompts ON for the first live run so you can watch each tap.

## Honest caveats
- Automating Hinge **violates its Terms of Service**; aggressive use can flag or ban an account. Cautious pacing lowers but does not remove that risk. Consider a non-critical account.
- Local **vision quality** on small Gemma is modest. The recipe leads with OCR text (`describe_screen`) so it works even on weak/text-only models; photo judgment improves with a larger multimodal model or a cloud brain.
- This is a hobby/research tool. Use responsibly and at your own risk.

## How it's built
- `recipes/hinge.yaml`, the agent's instructions, parameters, and the mirroir extension.
- `recipes/youtube-test.yaml`, the safe smoke test.
- `config/`, mirroir permissions + the Hinge UI guide installed to `~/.mirroir-mcp/`.
- `install.sh` / `run.sh`, setup and launch.

## License

MIT, see [LICENSE](LICENSE). Free to use, copy, and share with credit.
