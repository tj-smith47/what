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
sentence. Questions starting with `how`, `why`, `where`, `who` or `which` go
through unchanged (see [Aliases](#aliases) to install those as commands):

```console
$ what how do i list open ports on linux
ss -tulnp
```

It is a shell script around `claude -p` with a system prompt that asks for a
one line answer. Most answers come back in about two seconds.

- [Install](#install)
- [Usage](#usage)
  - [Piped input](#piped-input)
  - [Tools](#tools)
- [Aliases](#aliases)
- [How it works](#how-it-works)
- [License](#license)

## Install

Requires [Claude Code](https://claude.com/claude-code) on your PATH.

```bash
git clone https://github.com/tj-smith47/what.git
cd what
./install.sh                 # symlinks into ~/.local/bin, so git pull updates it
./install.sh /usr/local/bin  # or pick your own directory
```

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

```bash
what -m claude-opus-5 is the cheapest way to dedupe a 10GB file
WHAT_EFFORT=high what is the difference between epoll and io_uring
what -t WebSearch is the latest stable kubernetes version
```

### Piped input

Whatever comes in on stdin is sent along with the question. Without a question
it describes what it was given.

```bash
cargo build 2>&1 | what does this error mean
kubectl describe pod api-7d9f | what is wrong with this pod
cat weird_migration.sql | what
```

### Tools

By default it can read files in the current directory. It cannot write them or
use the network. So questions about the repo you are in work:

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

Pass `-t Bash,WebSearch` to add tools. `-t none` turns them all off and
`-t default` turns on the whole built-in set. Names can be separated with
commas or spaces, and `what --list-tools` prints every name your build accepts.

Questions that do not involve files take no extra time:

```console
$ time what does chmod 4755 mean
real    0m2.4s

$ time what does the -t flag default to in the what script here
real    0m6.7s
```

## Aliases

Since the command name is the first word of the question, other question words
can be installed as commands too:

```bash
what --add-alias how,why,when,where
```

Each one is a symlink next to `what`, pointing at the same script:

```console
$ how do i list open ports on linux
ss -tulpn

$ why does git say detached HEAD
You checked out a commit, tag, or remote branch directly instead of a local branch.

$ when was the first release of rust
Rust 0.1 was released January 20, 2012; Rust 1.0 came May 15, 2015.

$ where does systemd keep unit files
/etc/systemd/system (local, wins), /run/systemd/system (runtime), /usr/lib/systemd/system (packages).
```

A name that is already a command gets skipped. `who` and `which` are real
programs, and a symlink in front of them would break scripts that call them:

```console
$ what --add-alias who,which
what: 'who' is already /usr/bin/who, skipping (--force to shadow it)
what: 'which' is already /usr/bin/which, skipping (--force to shadow it)
```

To remove an alias, delete the symlink. `git pull` updates all of them at once.
Names outside the question words work as well; `explain` gets read as a `what`
question.

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

`--safe-mode` is why the answers are consistent. It skips your `CLAUDE.md`,
hooks, skills, plugins, MCP servers and settings, so a question gets the same
treatment on every machine and picks up nothing from whatever project you
happen to be in. `--permission-prompts none` means the script cannot stall on a
permission prompt in a non-interactive run. Session persistence is off, so
these do not show up in `claude --resume`.

## License

MIT
