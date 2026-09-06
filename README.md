# what

One-line answers to quick technical questions, piped through Claude Code.

```console
$ what is the sort flag for selecting the field to sort by
sort -k2   (use -k N for the Nth field, e.g. sort -k2,2 -t, file.csv)

$ what does chmod 4755 mean
rwxr-xr-x plus the setuid bit: the file runs as its owner.

$ kubectl apply -f x.yaml 2>&1 | what does this error mean
```

## Install

```bash
./install.sh              # ~/.local/bin/what (symlink, so git pull updates it)
./install.sh /usr/local/bin
```

## Options

| Flag | Env | Default |
|---|---|---|
| `-m, --model` | `WHAT_MODEL` | `claude-sonnet-5` |
| `-e, --effort` | `WHAT_EFFORT` | model's own (`low`\|`medium`\|`high`\|`xhigh`\|`max`) |
| `-t, --tools` | `WHAT_TOOLS` | none — `-t WebSearch` to let it look things up |

```bash
what -m claude-opus-5 is the cheapest way to dedupe a 10GB file
WHAT_EFFORT=high what is the difference between epoll and io_uring
what -t WebSearch is the latest stable kubernetes version
```

Runs `claude --safe-mode`, so your CLAUDE.md, hooks, skills, plugins and MCP
servers are not loaded — questions stay fast and context-free.
