#!/bin/bash
set -euo pipefail

# Only run in remote/web environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "==> Setting up Codex development environment..."

# Install Rust toolchain specified in rust-toolchain.toml (1.92.0)
echo "==> Installing Rust toolchain..."
rustup show active-toolchain || true
(cd "$CLAUDE_PROJECT_DIR/codex-rs" && rustup show)

# Install 'just' task runner if not present
if ! command -v just &>/dev/null; then
  echo "==> Installing 'just' task runner..."
  cargo install just
fi

# Pre-fetch Rust dependencies (cached by the container snapshot)
echo "==> Fetching Rust dependencies..."
(cd "$CLAUDE_PROJECT_DIR/codex-rs" && cargo fetch)

# Build the codex binary (required by SDK tests)
echo "==> Building codex binary..."
(cd "$CLAUDE_PROJECT_DIR/codex-rs" && cargo build -p codex-cli)

# Install Node.js / pnpm dependencies
echo "==> Installing pnpm dependencies..."
(cd "$CLAUDE_PROJECT_DIR" && pnpm install)

echo "==> Environment setup complete."
