# Claude Code Skills Collection

My personal collection of Claude Code skills, curated from [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills).

## Quick Start

### Clone & Install

```bash
# Clone with submodules
git clone --recurse-submodules git@github.com:ShunmeiCho/claude-code-skills.git ~/.claude/skills

# Or if you forgot --recurse-submodules
git clone git@github.com:ShunmeiCho/claude-code-skills.git ~/.claude/skills
cd ~/.claude/skills
git submodule update --init --recursive

# Run the setup script
cd ~/.claude/skills
./setup.sh
```

### Setup Options

```bash
./setup.sh              # Install all dependencies (Python + Node.js)
./setup.sh --all        # Same as above
./setup.sh --python     # Python dependencies only
./setup.sh --node       # Node.js dependencies only
./setup.sh --minimal    # Submodules only, no dependencies
```

### Manual Setup

If you prefer manual installation:

```bash
cd ~/.claude/skills

# 1. Global Python dependencies (for local skills)
pip install lxml pymupdf pypdf reportlab pillow openpyxl

# 2. NotebookLM skill (with venv)
cd notebooklm-skill
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
patchright install chrome
deactivate
cd ..

# 3. Node.js skills
cd playwright-skill && npm install && npx playwright install chromium && cd ..
cd n8n-skills && npm install && npm run build && cd ..
```

## Skills Overview

### Local Skills (No Dependencies)

These skills are prompt-only and work out of the box:

| Skill | Description |
|-------|-------------|
| `article-extractor` | Extract clean article content from URLs |
| `brainstorming` | Creative exploration before implementation |
| `changelog-generator` | Generate changelogs from git commits |
| `developer-growth-analysis` | Analyze coding patterns and growth |
| `file-organizer` | Intelligently organize files and folders |
| `finishing-a-development-branch` | Guide for completing dev branches |
| `git-pushing` | Smart git commit and push workflow |
| `kaizen` | Iterative improvement techniques |
| `prompt-engineering` | Writing effective prompts for LLMs |
| `review-implementing` | Process code review feedback |
| `software-architecture` | Quality-focused architecture guidance |
| `subagent-driven-development` | Dispatch subagents for parallel tasks |
| `terminal-title` | Update terminal title for task context |
| `test-driven-development` | TDD workflow guidance |
| `test-fixing` | Systematically fix failing tests |
| `using-git-worktrees` | Git worktree management |

### Local Skills (With Dependencies)

| Skill | Runtime | Dependencies | Setup Command |
|-------|---------|--------------|---------------|
| `docx` | Python | lxml | `pip install lxml` |
| `pdf` | Python | pypdf, pymupdf, reportlab, pillow | `pip install pypdf pymupdf reportlab pillow` |
| `pptx` | Python + Node.js | lxml, html2pptx | See skill directory |
| `xlsx` | Python | openpyxl | `pip install openpyxl` |
| `playwright-skill` | Node.js 18+ | playwright | `npm install && npx playwright install chromium` |
| `n8n-skills` | Node.js 18+ | n8n, typescript | `npm install && npm run build` |
| `notebooklm-skill` | Python 3.10+ | patchright | Uses venv, see setup.sh |

**Quick install all Python dependencies:**

```bash
pip install lxml pymupdf pypdf reportlab pillow openpyxl
```

### Third-Party Skills (Submodules)

These are included as git submodules and track their upstream repositories:

| Skill | Source | Description |
|-------|--------|-------------|
| `claude-d3js-skill` | [chrisvoncsefalvay](https://github.com/chrisvoncsefalvay/claude-d3js-skill) | D3.js data visualizations |
| `family-history-planning` | [emaynard](https://github.com/emaynard/claude-family-history-research-skill) | Genealogy research planning |
| `move-code-quality` | [1NickPappas](https://github.com/1NickPappas/move-code-quality-skill) | Move language code quality |
| `n8n-skills` | [haunchen](https://github.com/haunchen/n8n-skills) | n8n workflow automation |
| `notebooklm-skill` | [PleasePrompto](https://github.com/PleasePrompto/notebooklm-skill) | Google NotebookLM integration |
| `pict-test-designer` | [omkamal](https://github.com/omkamal/pypict-claude-skill) | PICT combinatorial testing |

## Updating

### Update All Submodules

```bash
cd ~/.claude/skills
git submodule update --remote --merge
```

### Update Specific Submodule

```bash
cd ~/.claude/skills/notebooklm-skill
git pull origin main
```

## Directory Structure

```
~/.claude/skills/
├── README.md
├── setup.sh                    # One-click setup script
├── .gitignore
├── .gitmodules                 # Submodule definitions
│
├── # Local skills (prompt-only)
├── article-extractor/
├── brainstorming/
├── changelog-generator/
├── ...
│
├── # Local skills (with scripts)
├── docx/
├── pdf/
├── playwright-skill/
├── ...
│
└── # Third-party submodules
    ├── claude-d3js-skill/
    ├── notebooklm-skill/
    └── ...
```

## Requirements

- **Git** 2.x+
- **Python** 3.10+ (for Python-based skills)
- **Node.js** 18+ (for Node.js-based skills)
- **Claude Code** CLI

## Troubleshooting

### Submodules are empty

```bash
git submodule update --init --recursive
```

### Permission denied on setup.sh

```bash
chmod +x setup.sh
./setup.sh
```

### NotebookLM skill browser issues

NotebookLM requires a display for browser automation. On headless servers:
- Use Xvfb for virtual display
- Or run authentication on a machine with display first

## License

Individual skills retain their original licenses. See each skill directory for details.

## Credits

Skills sourced from [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) community collection.
