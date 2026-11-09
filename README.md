<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# turnlint

[![CI](https://github.com/Gulliby-development/turnlint/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/turnlint/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

turnlint is a small, offline Swift command-line tool for checking chat transcripts before sending them to a model. It is for people building agents, replaying logs, or evaluating tool use. It does not call a model or require a network connection.

Run it from the repository directory with `swift run -q turnlint COMMAND`. The package declares a Swift 6.2 toolchain minimum. It is intended to build on Windows, macOS, and Linux; shell snippets below use POSIX syntax.

## Commands

```text
usage: turnlint check [--open] [--parallel N]
       turnlint pending
       turnlint repair
       turnlint stats
```

All commands read the transcript from standard input. Successful commands write their result to standard output and nothing to standard error. Failures write no standard output and one diagnostic line to standard error. Command-line errors exit with status 2; transcript errors exit with status 1.

The first argument selects a command. With no arguments, usage is written to standard error and the exit status is 2. An unknown command reports `turnlint: unknown command WORD`. The first argument `help`, `-h`, or `--help` prints usage and exits successfully, ignoring later arguments. Likewise, `--version` prints `turnlint 0.1.0` and exits successfully regardless of later arguments.

Only `check` accepts options. Arguments are validated from left to right, and the first invalid one is reported; invalid command lines are rejected before standard input is read. A non-option word (including an empty word or `-`) reports `turnlint: unexpected argument WORD`; an unsupported option reports `turnlint: unknown option WORD`. Repeating `--open` reports `turnlint: given twice: --open`. `--parallel` consumes the following word as its value: a second occurrence reports `turnlint: given twice: --parallel`, a missing value reports `turnlint: missing value for --parallel`, and a value that is not a decimal integer from 1 through 16 with no leading zero reports `turnlint: bad value for --parallel`. The default parallel limit is 8. The selected limit applies only to `check`; the other commands use 8.

## Transcript format and ordering

Each physical line is separated by a line feed. A carriage return immediately before a line feed is removed, and a final line without a line feed still counts. Empty lines, lines made only of spaces or tabs, and lines whose first word begins with `#` are skipped. Other lines are split into words on spaces and tabs, with surrounding whitespace ignored.

The supported turn forms are:

- `system`, `user`, or `assistant` (each is exactly one word)
- `call ID TOOL` for an assistant tool call
- `result ID` for a tool result

An ID is 1–8 lowercase letters or digits. A tool name is 1–12 lowercase letters or underscores. Call IDs must be unique, and each result must refer to an earlier call that has not already received a result. Results may arrive in any order. Pending IDs are listed in call order, comma-separated without spaces.

The transcript is limited to 60 physical lines, including blank and comment lines. More than 60 produces `turnlint: transcript is too long (max 60 lines)` before any other transcript diagnostic. Exactly 60 lines is allowed. Lines are then validated in order. For each non-skipped line, syntax is checked before ordering: an unrecognized first word reports `turnlint: line N: unknown turn WORD`; a wrong number of words reports `turnlint: line N: bad arguments for WORD`; malformed IDs report `turnlint: line N: bad id WORD`; and malformed tool names report `turnlint: line N: bad tool name WORD`. The first failing line ends processing.

Order rules are applied in this priority:

- `system` must be the first turn, or the error is `system must be the first turn`.
- `user` cannot follow pending calls (`calls pending: IDS`), another user (`user follows user`), or a result (`user follows result`), in that order.
- `assistant` cannot follow pending calls (`calls pending: IDS`); it also cannot precede a user turn (`assistant before any user turn`) or follow another assistant (`assistant follows assistant`).
- A call cannot precede a user turn (`call before any user turn`). When the previous turn is a result, no earlier call may still be pending (`calls pending: IDS`). Reusing an ID reports `duplicate call id ID`; exceeding the parallel limit reports `too many parallel calls (max N)`.
- A result for an unknown ID reports `unknown call id ID`; a repeated result reports `call ID already has a result`.

Every transcript error is prefixed with its original line number as `turnlint: line N: REASON`. When a strict check ends with calls still pending, it reports `turnlint: line N: calls pending: IDS`, where N is the line number of the last non-skipped turn. Call results are required before a following user or assistant turn, and before a call that follows a result turn. After a user or assistant turn, calls may begin; consecutive calls may remain pending up to the limit, and their results can be returned in any order.

## Command behavior and output

- **check** validates ordering and, by default, rejects pending calls at end of input. It prints `ok turns T calls C results R` on success. With `--open`, end-of-input pending calls are permitted and a second line `open IDS` lists them when present. An empty transcript prints `ok turns 0 calls 0 results 0`.
- **pending** validates the transcript while allowing calls to remain open. It prints one pending ID per line, in call order, or `none` when there are none.
- **repair** validates and completes the transcript by inserting `result ID` turns for outstanding calls, in call order, before a user or assistant, before a call that follows a result, and at end of input. Syntax on a source line is checked before any insertion at that point; diagnostics retain original source line numbers, and the 60-line limit applies to source lines only. Repair output uses one space between words, removes comments, blank lines, and extra whitespace, and ends each emitted turn with a line feed. Empty input produces empty output. A failure produces no partial output.
- **stats** validates while allowing calls to remain open. It prints eight lines: `turns T`, `system S`, `user U`, `assistant A`, `calls C`, `results R`, `parallel P`, and `tools LIST`. P is the highest simultaneous pending-call count (zero if there were no calls). LIST contains each called tool as `NAME=COUNT`, sorted in byte order and separated by spaces, or `tools none`.

For an empty transcript, `pending` prints `none`; `stats` prints zero counts and `tools none`. Transcript failures across all commands produce no standard output and use the diagnostic form `turnlint: line N: REASON` (except the transcript-length diagnostic above).

## Examples

In these examples, `turnlint` is a POSIX shell function that runs the executable from the repository directory:

```sh
turnlint() { swift run -q turnlint "$@"; }
```

The `2>&1` in the final example redirects standard error to standard output so both streams appear together.

```text
$ printf 'system\nuser\nassistant\n' | turnlint check
ok turns 3 calls 0 results 0
$ printf 'user\ncall a1 search\ncall b2 fetch\nresult b2\n' | turnlint pending; printf 'user\ncall a1 search\ncall b2 fetch\nresult b2\n' | turnlint check --open
a1
ok turns 4 calls 2 results 1
open a1
$ printf 'user\ncall a1 search\ncall b2 fetch\nresult b2\nassistant\n' | turnlint repair
user
call a1 search
call b2 fetch
result b2
result a1
assistant
$ printf 'user\nuser\n' | turnlint check 2>&1; printf 'user\ncall a1 search\ncall b2 search\nresult a1\n' | turnlint stats
turnlint: line 2: user follows user
turns 4
system 0
user 1
assistant 0
calls 2
results 1
parallel 2
tools search=2
```

## Development

Run these checks from the repository directory:

```sh
swift format lint --strict --recursive .
swift build
swift test
```

See [LICENSE](LICENSE) for the MIT license.

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R93).
