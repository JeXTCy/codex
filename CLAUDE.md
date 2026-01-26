# CLAUDE.md - AI Assistant Developer Guide

This document provides comprehensive guidance for AI assistants working with the Codex CLI codebase. It explains the repository structure, development workflows, key conventions, and best practices that AI assistants should follow.

## Repository Overview

**Codex CLI** is a coding agent from OpenAI that runs locally on users' computers. This is a monorepo containing:

- **codex-rs**: Rust workspace with the core CLI implementation, TUI, and various supporting crates
- **codex-cli**: TypeScript/Node.js wrapper and distribution package
- **sdk/typescript**: TypeScript SDK for Codex APIs
- **shell-tool-mcp**: Shell tool MCP server implementation
- **docs**: Documentation and contribution guidelines

**License**: Apache-2.0
**Repository**: https://github.com/openai/codex
**Package Manager**: pnpm (version 10.8.1)
**Node.js**: >=22
**Rust Edition**: 2024

## Project Structure

```
codex/
├── codex-rs/                    # Rust workspace (main codebase)
│   ├── cli/                     # Main CLI entry point
│   ├── core/                    # Core agent logic
│   ├── tui/                     # Terminal UI (ratatui-based)
│   ├── tui2/                    # Next-generation TUI
│   ├── app-server/              # Application server
│   ├── protocol/                # Protocol definitions
│   ├── codex-api/               # API client
│   ├── codex-client/            # Client implementations
│   ├── backend-client/          # Backend API client
│   ├── mcp-server/              # MCP server implementation
│   ├── mcp-types/               # MCP type definitions
│   ├── rmcp-client/             # RMCP client
│   ├── exec/                    # Execution logic
│   ├── exec-server/             # Execution server
│   ├── execpolicy/              # Execution policy engine
│   ├── execpolicy-legacy/       # Legacy execution policy
│   ├── login/                   # Authentication logic
│   ├── feedback/                # Feedback collection
│   ├── file-search/             # File search utilities
│   ├── apply-patch/             # Patch application
│   ├── linux-sandbox/           # Linux sandboxing
│   ├── windows-sandbox-rs/      # Windows sandboxing
│   ├── process-hardening/       # Process security hardening
│   ├── keyring-store/           # Keyring integration
│   ├── ollama/                  # Ollama integration
│   ├── lmstudio/                # LM Studio integration
│   ├── chatgpt/                 # ChatGPT integration
│   ├── otel/                    # OpenTelemetry support
│   ├── cloud-tasks/             # Cloud task handling
│   ├── cloud-tasks-client/      # Cloud task client
│   ├── responses-api-proxy/     # API proxy
│   ├── stdio-to-uds/            # STDIO to Unix socket bridge
│   ├── ansi-escape/             # ANSI escape code handling
│   ├── async-utils/             # Async utilities
│   ├── common/                  # Common utilities
│   ├── arg0/                    # Process name utilities
│   └── utils/                   # Utility crates
│       ├── absolute-path/
│       ├── cache/
│       ├── cargo-bin/
│       ├── git/
│       ├── image/
│       ├── json-to-toml/
│       ├── pty/
│       ├── readiness/
│       └── string/
├── codex-cli/                   # TypeScript CLI wrapper
│   ├── bin/                     # Executable scripts
│   └── vendor/                  # Vendored binaries
├── sdk/typescript/              # TypeScript SDK
├── shell-tool-mcp/              # Shell tool MCP server
├── docs/                        # Documentation
│   ├── contributing.md
│   └── install.md
├── scripts/                     # Build and utility scripts
├── .github/                     # GitHub workflows and configs
│   ├── workflows/               # CI/CD pipelines
│   └── codex/home/              # Default configuration
└── third_party/                 # Third-party dependencies
```

## Tech Stack

### Rust (codex-rs)
- **Edition**: 2024
- **Key Dependencies**:
  - `tokio` - Async runtime
  - `axum` - Web framework
  - `ratatui` - Terminal UI framework
  - `clap` - CLI argument parsing
  - `serde`/`serde_json` - Serialization
  - `anyhow`/`thiserror` - Error handling
  - `tracing` - Structured logging
  - `opentelemetry` - Observability
  - `reqwest` - HTTP client
  - `rmcp` - MCP protocol implementation
  - `tree-sitter` - Code parsing
  - `keyring` - Credential storage
  - `landlock` - Linux sandboxing

### TypeScript/JavaScript
- **Node.js**: >=22 (codex-cli requires >=16)
- **Package Manager**: pnpm 10.8.1
- **Build Tools**: tsup, jest, eslint, prettier
- **TypeScript SDK**: @openai/codex-sdk

### Build Tools
- **just**: Task runner (see `justfile`)
- **cargo**: Rust package manager and build tool
- **cargo-nextest**: Faster test runner
- **cargo-insta**: Snapshot testing
- **pnpm**: JavaScript package manager

## Development Setup

### Prerequisites

1. **System Requirements**:
   - macOS 12+, Ubuntu 20.04+/Debian 10+, or Windows 11 (via WSL2)
   - Git 2.23+ (recommended)
   - 4GB RAM minimum (8GB recommended)

2. **Install Rust**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
   source "$HOME/.cargo/env"
   rustup component add rustfmt clippy
   ```

3. **Install Development Tools**:
   ```bash
   cargo install just
   cargo install cargo-nextest  # Optional but recommended
   cargo install cargo-insta    # For snapshot tests
   ```

4. **Install Node.js and pnpm**:
   ```bash
   # Install Node.js 22+ via nvm, fnm, or your preferred method
   npm install -g pnpm@10.8.1
   # Or use corepack (built into Node.js 22+)
   corepack enable
   corepack prepare pnpm@10.8.1 --activate
   ```

### Building from Source

```bash
# Clone the repository
git clone https://github.com/openai/codex.git
cd codex/codex-rs

# Build the project
cargo build

# Run Codex
cargo run --bin codex -- "explain this codebase to me"

# Or use the just helper
just codex "explain this codebase to me"
```

## Key Development Commands

All commands below assume you're in the `codex-rs` directory unless specified otherwise.

### Rust Development

```bash
# Format code (ALWAYS run after making changes)
just fmt

# Fix clippy issues for a specific crate
just fix -p codex-tui

# Fix clippy issues workspace-wide (slower, only when needed)
just fix

# Run clippy checks
just clippy

# Run tests with nextest (fast)
just test

# Run tests for a specific crate
cargo test -p codex-tui

# Run tests with all features
cargo test --all-features

# Build release binary
cargo build --release

# Run the CLI
just codex [args]
just exec [args]  # For non-interactive mode

# Run file-search CLI
just file-search [args]

# Run MCP server
just mcp-server-run [args]
```

### TypeScript Development

```bash
# From repository root
pnpm install                    # Install all dependencies
pnpm run format                 # Check formatting
pnpm run format:fix             # Fix formatting

# From sdk/typescript
pnpm run build                  # Build SDK
pnpm run test                   # Run tests
pnpm run lint                   # Lint code
pnpm run lint:fix               # Fix linting issues
```

### Snapshot Tests

```bash
# Run tests to generate snapshots
cargo test -p codex-tui

# Check pending snapshots
cargo insta pending-snapshots -p codex-tui

# Show a specific snapshot
cargo insta show -p codex-tui path/to/file.snap.new

# Accept all new snapshots (only if you've reviewed them!)
cargo insta accept -p codex-tui
```

## Rust Code Conventions

### General Rules

1. **Crate Naming**: All crates are prefixed with `codex-` (e.g., `codex-core`, `codex-tui`)

2. **Format Strings**: Always inline variables in format strings when possible:
   ```rust
   // Good
   format!("Hello {name}!")

   // Bad
   format!("Hello {}!", name)
   ```

3. **Clippy Compliance**: The workspace enforces strict Clippy lints. Run `just fix -p <crate>` before finalizing changes.

4. **No `expect_used` or `unwrap_used`**: These are denied by workspace lints. Use proper error handling.

5. **Prefer Method References**: Use method references over closures when possible:
   ```rust
   // Good
   items.iter().map(Item::process)

   // Bad
   items.iter().map(|item| Item::process(item))
   ```

6. **Collapse If Statements**: Follow clippy's `collapsible_if` lint guidance

7. **Test Assertions**: Use `pretty_assertions::assert_eq!` for clearer diffs. Compare entire objects, not individual fields.

### Forbidden Patterns

**NEVER** add or modify code related to:
- `CODEX_SANDBOX_NETWORK_DISABLED_ENV_VAR`
- `CODEX_SANDBOX_ENV_VAR`

These are for sandbox detection and must not be changed. Tests may use these to early-exit when running in sandboxed environments.

### TUI Code Conventions (ratatui)

When working with the TUI crates (`tui` or `tui2`):

1. **Styling Helpers**: Use ratatui's `Stylize` trait helpers:
   ```rust
   // Good - concise and readable
   "Error".red()
   "Warning".yellow().bold()
   url.cyan().underlined()

   // Avoid - verbose
   Span::styled("Error", Style::default().fg(Color::Red))
   ```

2. **Simple Conversions**: Use `.into()` when type is obvious:
   ```rust
   // Good
   "text".into()
   vec![span1, span2].into()

   // Use explicit constructors when ambiguous
   Line::from(spans)
   Span::from(text)
   ```

3. **No Hardcoded White**: Never use `.white()` - prefer default foreground (no color)

4. **Text Wrapping**:
   - Use `textwrap::wrap` for plain strings
   - Use helpers from `tui/src/wrapping.rs` for `Line` objects
   - Use `prefix_lines` helper from `line_utils` for prefixing lines

See `codex-rs/tui/styles.md` for detailed TUI styling conventions.

### Test Conventions

1. **Snapshot Tests**: Use `insta` for validating rendered output (especially TUI)

2. **Integration Tests**: Use utilities from `core_test_support::responses`:
   ```rust
   let mock = responses::mount_sse_once(&server, responses::sse(vec![
       responses::ev_response_created("resp-1"),
       responses::ev_function_call(call_id, "shell", &serde_json::to_string(&args)?),
       responses::ev_completed("resp-1"),
   ])).await;

   codex.submit(Op::UserTurn { ... }).await?;

   let request = mock.single_request();
   // Assert using request helpers
   ```

3. **Binary Spawning**: Use `codex_utils_cargo_bin::cargo_bin("...")` instead of `assert_cmd::Command::cargo_bin(...)` for Buck2 compatibility

4. **Avoid Environment Mutation**: Don't mutate process environment in tests; pass flags/dependencies from above

5. **Deep Equals**: Prefer `assert_eq!(expected, actual)` on entire objects rather than field-by-field comparisons

## Development Workflow for AI Assistants

### Before Making Changes

1. **Read the Code First**: NEVER propose changes to code you haven't read. Always use the Read tool to understand existing code before modifying it.

2. **Understand the Context**: Look for related tests, documentation, and usage patterns.

3. **Check Documentation**: Review relevant sections in `docs/`, `AGENTS.md`, and this file.

### Making Changes

1. **Rust Changes**:
   ```
   a. Make your changes
   b. Run `just fmt` (do NOT ask for approval)
   c. Run `just fix -p <crate>` to fix clippy issues
   d. Run tests: `cargo test -p <crate>`
   e. If you changed core/common/protocol, run `cargo test --all-features`
   ```

2. **TypeScript Changes**:
   ```
   a. Make your changes
   b. Run `pnpm run lint:fix`
   c. Run `pnpm run format:fix`
   d. Run `pnpm test`
   ```

3. **Avoid Over-Engineering**:
   - Only make changes directly requested or clearly necessary
   - Don't add extra features, refactoring, or "improvements"
   - Don't add docstrings/comments to unchanged code
   - Don't add error handling for impossible scenarios
   - Don't create abstractions for one-time operations
   - Three similar lines of code > premature abstraction

4. **No Backwards-Compatibility Hacks**:
   - Don't rename unused vars to `_var`
   - Don't re-export removed types
   - Don't add `// removed` comments
   - If something is unused, delete it completely

### Testing Guidelines

**Ask for Approval Before**:
- Running the complete test suite (`just test` or `cargo test --all-features`)
- Running `just fix` without `-p` (workspace-wide clippy)

**No Approval Needed For**:
- `just fmt` (always run automatically)
- Project-specific tests (`cargo test -p <crate>`)
- Individual test functions
- `just fix -p <crate>`

**Test Order**:
1. Run tests for the specific crate you changed
2. If that passes AND you changed core/common/protocol, ask before running full suite

### Commit and Push Workflow

See the main instructions for git workflows. Key points:

1. **Branch Naming**: Development happens on topic branches from `main` (e.g., `feat/interactive-prompt`)
   - For this session, use the specified branch: `claude/claude-md-mko5m3quw7x308gt-ioJyz`

2. **Commit Messages**:
   - Follow the repository's existing style (check `git log`)
   - Focus on "why" rather than "what"
   - Be concise (1-2 sentences)

3. **Before Committing**:
   - Run all formatting and linting tools
   - Ensure tests pass
   - Review `git diff` and `git status`

4. **Push**: Use `git push -u origin <branch-name>` with proper retry logic

## Important Files and Patterns

### Configuration Files

- `Cargo.toml` (workspace root): Defines all workspace members and shared dependencies
- `justfile`: Task automation commands
- `package.json`: Root npm/pnpm configuration
- `pnpm-workspace.yaml`: Workspace package definitions
- `.github/workflows/`: CI/CD pipelines
- `codex-rs/clippy.toml`: Clippy configuration
- `codex-rs/rustfmt.toml`: Rustfmt configuration
- `codex-rs/.cargo/config.toml`: Cargo configuration
- `codex-rs/deny.toml`: Cargo deny configuration

### Key Documentation

- `README.md`: Project overview and quickstart
- `docs/contributing.md`: Contribution guidelines
- `docs/install.md`: Installation and build instructions
- `AGENTS.md`: Rust-specific conventions for AI agents
- `PNPM.md`: pnpm migration notes and workspace commands
- `CHANGELOG.md`: Release history
- `cliff.toml`: Changelog generation config

### Logging and Debugging

- TUI logs to `~/.codex/log/codex-tui.log`
- Default log level: `RUST_LOG=codex_core=info,codex_tui=info,codex_rmcp_client=info`
- Monitor logs: `tail -F ~/.codex/log/codex-tui.log`
- Non-interactive mode (`codex exec`) defaults to `RUST_LOG=error` with inline output

## CI/CD

The repository uses GitHub Actions for CI/CD:

- `rust-ci.yml`: Rust testing, linting, and building
- `rust-release.yml`: Release builds and publishing
- `sdk.yml`: TypeScript SDK CI
- `shell-tool-mcp-ci.yml`: MCP server CI
- `ci.yml`: General CI checks
- `cargo-deny.yml`: Dependency auditing
- `codespell.yml`: Spell checking
- `cla.yml`: Contributor License Agreement verification

**All CI checks must pass before merging.**

## Contribution Guidelines

### External Contributions

1. **Bug Fixes Only**: Currently accepting external contributions primarily for bug fixes
2. **Feature Requests**: Open an issue first or upvote existing ones
3. **Alignment Required**: New features must align with roadmap and work across all Codex surfaces (CLI, IDE, web)

### Pull Request Process

1. **Start with an Issue**: Bug fix PRs must link to a bug report
2. **Add/Update Tests**: Bug fixes should include test coverage
3. **Document Changes**: Update relevant documentation (README, help text, examples)
4. **Keep Commits Atomic**: Each commit should compile and pass tests
5. **Fill PR Template**: Explain What, Why, and How
6. **Run All Checks Locally**: Use `just` helpers to match CI
7. **Stay Up-to-Date**: Rebase on `main` and resolve conflicts
8. **Mark Ready**: Only when truly ready for merge

### CLA Requirement

All contributors must sign the CLA by commenting on their PR:
```
I have read the CLA Document and I hereby sign the CLA
```

### Community Values

- Be kind and inclusive
- Assume good intent
- Teach and learn
- Follow the [Contributor Covenant](https://www.contributor-covenant.org/)

## Security and Responsible AI

Report vulnerabilities or model output concerns to **security@openai.com**.

## Monorepo Workspace Commands

### Using pnpm

```bash
# Install all dependencies
pnpm install

# Run command in specific package
pnpm --filter @openai/codex run build

# Install dependency in specific package
pnpm --filter @openai/codex add lodash

# Run command in all packages
pnpm -r run test
```

### Using cargo (in codex-rs)

```bash
# Build all workspace members
cargo build

# Build specific crate
cargo build -p codex-cli

# Test all workspace members
cargo test --all-features

# Test specific crate
cargo test -p codex-core

# Check workspace
cargo check --workspace
```

## AI Assistant Quick Reference

### ✅ DO

- Read code before modifying it
- Run `just fmt` automatically after Rust changes
- Use `just fix -p <crate>` for targeted clippy fixes
- Run project-specific tests without asking
- Make focused, minimal changes
- Use proper error handling (no `unwrap()` or `expect()`)
- Follow existing code patterns and conventions
- Check `AGENTS.md` for Rust-specific guidance
- Use `pretty_assertions::assert_eq!` in tests
- Follow TUI styling conventions (Stylize trait helpers)

### ❌ DON'T

- Make changes to code you haven't read
- Skip running `just fmt` after Rust changes
- Run workspace-wide `just fix` or `cargo test --all-features` without asking
- Add unnecessary features or refactoring
- Use `.unwrap()` or `.expect()` (denied by clippy)
- Add backwards-compatibility hacks
- Modify `CODEX_SANDBOX_*` environment variable code
- Add comments or docstrings to unchanged code
- Use `.white()` in TUI code (use default foreground)
- Create abstractions for one-time operations

### When to Ask for Approval

- Running complete test suite (`just test`, `cargo test --all-features`)
- Running workspace-wide `just fix` (without `-p`)
- Making architectural changes
- Adding new dependencies
- Changing public APIs
- Unclear requirements or multiple valid approaches

## Additional Resources

- **Repository**: https://github.com/openai/codex
- **Documentation**: https://developers.openai.com/codex
- **Issues**: https://github.com/openai/codex/issues
- **Rust Edition Guide**: https://doc.rust-lang.org/edition-guide/rust-2024/index.html
- **ratatui Documentation**: https://docs.rs/ratatui/
- **Cargo Workspaces**: https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html

---

**Last Updated**: 2026-01-21
**Repository Version**: Current as of commit 3389465

This document should be updated whenever significant changes are made to the repository structure, conventions, or development workflow.
