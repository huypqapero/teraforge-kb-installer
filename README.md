# kb-team Installer

Public installer for the **private** `huypqapero/team-knowledge` KB.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/huypqapero/kb-team-installer/main/install.sh | bash
```

With auto-sync hooks:
```bash
curl -fsSL https://raw.githubusercontent.com/huypqapero/kb-team-installer/main/install.sh | bash -s -- --with-hooks
```

## Prerequisite

- `git`, `curl`, `gh` (GitHub CLI)
- GitHub account với access vào private repo `huypqapero/team-knowledge`

Installer will:
1. Prompt `gh auth login` nếu chưa authenticated
2. Install `uv` (static binary ~10MB) nếu chưa có
3. Download Python 3.11 managed (isolated, không touch system Python)
4. `gh repo clone` private KB → `~/.kb-team/`
5. Install MCP tools + Claude skill + optional hooks

Full install ~2 min, ~130MB disk.

## What gets installed

```
~/.kb-team/                   ← Private KB cloned
~/.local/bin/kb-team          ← CLI symlink
~/.local/share/uv/python/     ← Python 3.11 managed (~15MB)
~/.local/share/uv/tools/      ← basic-memory + team-knowledge-mcp (~100MB)
~/.claude/skills/kb-team/     ← Claude skill
~/.claude.json                ← MCP wired (atomic merge, backup)
```

## Uninstall

```bash
kb-team uninstall           # Remove install
kb-team uninstall --purge   # Also remove uv + Python managed
```

## Related

- Private KB repo: https://github.com/huypqapero/team-knowledge
- Wrapper source: https://github.com/huypqapero/team-knowledge/tree/main/wrapper (team-knowledge-mcp fork v0.3.0)

## Troubleshoot

- **404 raw install.sh** → `curl -L` theo URL raw.githubusercontent.com, repo này **public**, không cần auth
- **gh auth fail** → Repo private; dev phải có GitHub account được invite + `gh auth login` chạy xong
- **Permission denied clone** → Confirm account `gh auth status` khớp account có repo access
