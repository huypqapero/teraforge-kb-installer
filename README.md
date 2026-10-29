# TeraForge KB Installer

Public installer for the **private** `huypqapero/teraforge-kb` KB — knowledge base cho BA, Dev và QA tại Terasoft.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/huypqapero/teraforge-kb-installer/main/install.sh | bash
```

With auto-sync hooks:
```bash
curl -fsSL https://raw.githubusercontent.com/huypqapero/teraforge-kb-installer/main/install.sh | bash -s -- --with-hooks
```

## Prerequisite

- `git`, `curl`, `gh` (GitHub CLI)
- GitHub account với access vào private repo `huypqapero/teraforge-kb`

Installer will:
1. Prompt `gh auth login` nếu chưa authenticated
2. Install `uv` (static binary ~10MB) nếu chưa có
3. Download Python 3.11 managed (isolated, không touch system Python)
4. `gh repo clone` private KB → `~/.tfkb/`
5. Install MCP tools + Claude skill + optional hooks

Full install ~2 min, ~130MB disk.

## What gets installed

```
~/.tfkb/                   ← Private KB cloned
~/.local/bin/tfkb          ← CLI symlink
~/.local/share/uv/python/     ← Python 3.11 managed (~15MB)
~/.local/share/uv/tools/      ← basic-memory + teraforge-kb-mcp (~100MB)
~/.claude/skills/tfkb/     ← Claude skill
~/.claude.json                ← MCP wired (atomic merge, backup)
```

## Uninstall

```bash
tfkb uninstall           # Remove install
tfkb uninstall --purge   # Also remove uv + Python managed
```

## Related

- Private KB repo: https://github.com/huypqapero/teraforge-kb
- Wrapper source: https://github.com/huypqapero/teraforge-kb/tree/main/wrapper (teraforge-kb-mcp fork v0.3.0)

## Troubleshoot

- **404 raw install.sh** → `curl -L` theo URL raw.githubusercontent.com, repo này **public**, không cần auth
- **gh auth fail** → Repo private; dev phải có GitHub account được invite + `gh auth login` chạy xong
- **Permission denied clone** → Confirm account `gh auth status` khớp account có repo access
