# what

Ask your terminal a question, get one line back.

```console
$ what is the sort flag for selecting the field to sort by
sort -k N (e.g. sort -k2)

$ what does chmod 4755 mean
Sets setuid plus rwxr-xr-x: owner rwx, group r-x, others r-x, and the program runs as the file owner.

$ git checkout mian 2>&1 | what does this mean
You typo'd the branch name. Git found no branch or file called "mian". You probably meant "main".
```

The command name is the first word of the question, so `what is X` reads as a
sentence. Questions that start with `how`, `why`, `where`, `who` or `which` are
passed through as written:

```console
$ what how do i list open ports on linux
ss -tulnp
```

## Why

Because opening a chat window to remember a flag costs more than the flag is
worth. This is a shell script around `claude -p`, tuned so the answer fits on
one line and arrives in about two seconds.

## Install

Requires [Claude Code](https://claude.com/claude-code) on your PATH.

```bash
git clone https://github.com/tj-smith47/what.git
cd what
./install.sh                 # symlinks into ~/.local/bin, so git pull updates it
./install.sh /usr/local/bin  # or pick your own directory
```

## Aliases

`what` reads the command name as the first word of your question, so install a
few more names and the rest of the question words work the same way:

```bash
what --add-alias how,why,when,where,who,which
```

They land next to `what` itself, pointing at the same script:

```console
$ how do i list open ports on linux
ss -tulpn

$ why does git say detached HEAD
You checked out a commit, tag, or remote branch directly instead of a local branch.

$ when was the first release of rust
Rust 0.1 was released January 20, 2012; Rust 1.0 came May 15, 2015.

$ where does systemd keep unit files
/etc/systemd/system (local, wins), /run/systemd/system (runtime), /usr/lib/systemd/system (packages).

$ who owns the files in /var/lib/docker
Typically root, since the Docker daemon runs as root by default.

$ which sort flag makes it numeric
sort -n
```

Every alias is a symlink, so `rm ~/.local/bin/how` removes one and a `git pull`
updates them all. Question words are the useful set, but any name works:
something like `explain` falls back to reading as a `what` question.

## Usage

```
what [options] <question>
cmd 2>&1 | what does this mean
```

| Option | Environment | Default |
| ------ | ----------- | ------- |
| `-m, --model` | `WHAT_MODEL` | `claude-sonnet-5` |
| `-e, --effort` | `WHAT_EFFORT` | `auto`, else `low` \| `medium` \| `high` \| `xhigh` \| `max` |
| `-t, --tools` | `WHAT_TOOLS` | `Read,Glob,Grep` |
| `--list-tools` | | print the tool names your Claude Code build accepts |

```bash
what -m claude-opus-5 is the cheapest way to dedupe a 10GB file
WHAT_EFFORT=high what is the difference between epoll and io_uring
what -t WebSearch is the latest stable kubernetes version
```

### Piped input

Anything piped in becomes context for the question, which makes it a decent
error explainer. With no question at all, it just explains what it was given.

```bash
cargo build 2>&1 | what does this error mean
kubectl describe pod api-7d9f | what is wrong with this pod
cat weird_migration.sql | what
```

### Tools

By default it can look at your files but cannot change them or reach the
network, so questions about the repo you are standing in work:

```console
$ what does the -t flag default to in the what script here
Defaults to Read,Glob,Grep (overridable via env var WHAT_TOOLS).
```

| Tool | What it does | On by default |
| ---- | ------------ | ------------- |
| `Read` | opens a file | yes |
| `Glob` | finds files by path pattern | yes |
| `Grep` | searches file contents | yes |
| `Bash` | runs commands | no, it can change things |
| `WebSearch`, `WebFetch` | looks things up online | no, slower |

Widen with `-t Bash,WebSearch`, go fully offline with `-t none`, or hand it
everything with `-t default`. Names are comma or space separated, and
`what --list-tools` prints the full set your build accepts.

Questions that need no files skip the detour, so the common case stays fast:

```console
$ time what does chmod 4755 mean
real    0m2.4s

$ time what does the -t flag default to in the what script here
real    0m6.7s
```

## How it works

```
what is the sort flag ...
   |
   v
claude -p --safe-mode --no-session-persistence --tools Read,Glob,Grep
         --permission-prompts none --system-prompt "<answer in one line>"
   |
   v
sort -k N (e.g. sort -k2)
```

`--safe-mode` is doing the heavy lifting. It means your `CLAUDE.md`, hooks,
skills, plugins, MCP servers and custom settings are never loaded, so a
question here behaves the same on every machine and never inherits a project's
context. `--permission-prompts none` guarantees the script cannot sit waiting
for an approval that nobody is there to give, and session persistence is off so
your history does not fill with one line questions.

## License

MIT
