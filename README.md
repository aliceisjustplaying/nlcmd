# nlcmd

Type natural language in your terminal, press Ctrl+G, get a shell command.

## Install

```bash
bun install
```

## Setup

Add to your `~/.zshrc`:

```zsh
source /path/to/widget.zsh
export ANTHROPIC_API_KEY="sk-..."
```

## Usage

1. Type a natural language description of what you want to do
2. Press `Ctrl+G`
3. Watch the command stream in
4. Press Enter to execute (or edit first)

## Examples

```
find all pdf files in downloads ⟶ find ~/Downloads -name "*.pdf"
list git branches by date       ⟶ git branch --sort=-committerdate
disk usage top 10 folders       ⟶ du -h --max-depth=1 | sort -hr | head -10
```

## How it works

- `cli.ts` - Bun script using Vercel AI SDK + Claude Haiku 4.5
- `widget.zsh` - ZSH widget with streaming output via FIFO + animated spinner
