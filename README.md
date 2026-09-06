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
| `-e, --effort` | `WHAT_EFFORT` | `auto` — else `low`\|`medium`\|`high`\|`xhigh`\|`max` |
| `-t, --tools` | `WHAT_TOOLS` | `Read,Glob,Grep` — read-only, local, no network |

`auto` means the flag is not passed, so the model's own default effort applies
(`claude --effort auto` is rejected; omitting it is how you get auto).

By default it can look at your files (`Read` opens one, `Glob` finds them by
path pattern, `Grep` searches their contents) but cannot change them or reach
the network, so `what does the -t flag default to in the what script here`
works in a repo. Add `Bash` to let it run commands, `WebSearch`/`WebFetch` to
let it look things up online, `-t none` for a pure offline answer, `-t default`
for everything. Names are comma- or space-separated.

`what --list-tools` prints the names your claude build accepts. MCP servers,
skills and plugins are deliberately unreachable — `--safe-mode` turns them off.

```bash
what -m claude-opus-5 is the cheapest way to dedupe a 10GB file
WHAT_EFFORT=high what is the difference between epoll and io_uring
what -t WebSearch is the latest stable kubernetes version
```

Runs `claude --safe-mode`, so your CLAUDE.md, hooks, skills, plugins and MCP
servers are not loaded — questions stay fast and context-free.
