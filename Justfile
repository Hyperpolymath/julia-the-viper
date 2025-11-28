# Justfile for Julia the Viper

# Default recipe to display help information
default:
    @just --list

# Build all packages
build:
    @echo "Building JtV packages..."
    cd packages/jtv-lang && cargo build --release
    @echo "✓ jtv-lang built"

# Build for WASM
build-wasm:
    @echo "Building WASM target..."
    cd packages/jtv-lang && wasm-pack build --target web --out-dir ../../dist/wasm
    @echo "✓ WASM build complete"

# Run tests for all packages
test:
    @echo "Running Rust tests..."
    cd packages/jtv-lang && cargo test
    @echo "Running Deno tests..."
    cd packages/jtv-analyzer && deno test --allow-read
    @echo "✓ All tests passed"

# Run benchmarks
bench:
    @echo "Running benchmarks..."
    cd packages/jtv-lang && cargo bench
    @echo "✓ Benchmarks complete"

# Format code
fmt:
    @echo "Formatting Rust code..."
    cd packages/jtv-lang && cargo fmt
    @echo "Formatting TypeScript code..."
    cd packages/jtv-analyzer && deno fmt
    @echo "✓ Code formatted"

# Lint code
lint:
    @echo "Linting Rust code..."
    cd packages/jtv-lang && cargo clippy -- -D warnings
    @echo "Linting TypeScript code..."
    cd packages/jtv-analyzer && deno lint
    @echo "✓ Linting complete"

# Run a JtV file
run file:
    @echo "Running {{file}}..."
    cargo run --manifest-path packages/jtv-lang/Cargo.toml -- run {{file}}

# Parse a JtV file and display AST
parse file:
    @echo "Parsing {{file}}..."
    cargo run --manifest-path packages/jtv-lang/Cargo.toml -- parse {{file}}

# Analyze a legacy code file
analyze file lang="javascript":
    @echo "Analyzing {{file}} as {{lang}}..."
    cd packages/jtv-analyzer && deno run --allow-read src/main.ts {{file}} {{lang}}

# Build documentation
docs:
    @echo "Building documentation..."
    cd packages/jtv-lang && cargo doc --no-deps --open
    @echo "✓ Documentation built"

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    cd packages/jtv-lang && cargo clean
    rm -rf dist/
    rm -rf target/
    @echo "✓ Clean complete"

# Install development dependencies
install:
    @echo "Installing Rust toolchain..."
    rustup update stable
    rustup target add wasm32-unknown-unknown
    @echo "Installing wasm-pack..."
    cargo install wasm-pack
    @echo "✓ Dependencies installed"

# Run all checks (format, lint, test)
check: fmt lint test
    @echo "✓ All checks passed"

# Create a new release
release version:
    @echo "Creating release {{version}}..."
    # Update version in Cargo.toml
    sed -i 's/version = ".*"/version = "{{version}}"/' packages/jtv-lang/Cargo.toml
    # Build release
    just build
    just build-wasm
    # Tag release
    git tag -a v{{version}} -m "Release {{version}}"
    @echo "✓ Release {{version}} created"

# Watch for changes and rebuild
watch:
    @echo "Watching for changes..."
    cargo watch -x 'build --manifest-path packages/jtv-lang/Cargo.toml'

# Run example
example name:
    @echo "Running example: {{name}}"
    just run examples/basic/{{name}}.jtv

# Run smart contract example
contract name:
    @echo "Running contract: {{name}}"
    just run examples/contracts/{{name}}.jtv

# Generate code coverage
coverage:
    @echo "Generating code coverage..."
    cd packages/jtv-lang && cargo tarpaulin --out Html --output-dir ../../coverage
    @echo "✓ Coverage report in coverage/index.html"

# Start development server for playground
dev-playground:
    @echo "Starting playground development server..."
    cd playground && npm run dev

# Build playground for production
build-playground:
    @echo "Building playground..."
    cd playground && npm run build
    @echo "✓ Playground built in playground/dist"

# Run LSP server
lsp:
    @echo "Starting LSP server..."
    cargo run --manifest-path tools/lsp/Cargo.toml

# Package for distribution
package: build build-wasm
    @echo "Creating distribution package..."
    mkdir -p dist/bin
    cp packages/jtv-lang/target/release/jtv-lang dist/bin/jtv
    tar -czf dist/jtv-{{version}}.tar.gz -C dist bin/ wasm/
    @echo "✓ Package created: dist/jtv-{{version}}.tar.gz"

# Run all examples
run-all-examples:
    @echo "Running all basic examples..."
    just example 01_hello_addition
    just example 02_number_systems
    just example 03_functions
    just example 04_loops
    just example 05_conditionals
    @echo "Running all advanced examples..."
    just run examples/advanced/fibonacci.jtv
    just run examples/advanced/matrix_operations.jtv
    @echo "✓ All examples completed"

# Initialize git hooks
init-hooks:
    @echo "Installing git hooks..."
    echo '#!/bin/sh\njust check' > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    @echo "✓ Git hooks installed"

# Quick development cycle: format, lint, test, run
dev file: fmt lint test
    just run {{file}}

# Check RSR (Rhodium Standard Repository) compliance
rsr-check:
    @echo "Checking RSR compliance..."
    cd tools/cli && cargo run -- rsr-check
    @echo "✓ RSR compliance check complete"

# Validate repository meets RSR Gold standard
validate: rsr-check
    @echo "Validating repository structure..."
    @test -f README.adoc || (echo "❌ README.adoc missing" && exit 1)
    @test -f LICENSE.txt || (echo "❌ LICENSE.txt missing" && exit 1)
    @test -f GOVERNANCE.adoc || (echo "❌ GOVERNANCE.adoc missing" && exit 1)
    @test -f CONTRIBUTING.adoc || (echo "❌ CONTRIBUTING.adoc missing" && exit 1)
    @test -f CODE_OF_CONDUCT.adoc || (echo "❌ CODE_OF_CONDUCT.adoc missing" && exit 1)
    @test -f SECURITY.md || (echo "❌ SECURITY.md missing" && exit 1)
    @test -f CHANGELOG.md || (echo "❌ CHANGELOG.md missing" && exit 1)
    @test -f TPCF.md || (echo "❌ TPCF.md missing" && exit 1)
    @test -f REVERSIBILITY.md || (echo "❌ REVERSIBILITY.md missing" && exit 1)
    @test -f .well-known/security.txt || (echo "❌ .well-known/security.txt missing" && exit 1)
    @test -f .well-known/ai.txt || (echo "❌ .well-known/ai.txt missing" && exit 1)
    @test -f .well-known/humans.txt || (echo "❌ .well-known/humans.txt missing" && exit 1)
    @test -f .well-known/consent-required.txt || (echo "❌ .well-known/consent-required.txt missing" && exit 1)
    @test -f .well-known/provenance.json || (echo "❌ .well-known/provenance.json missing" && exit 1)
    @test -f Justfile || (echo "❌ Justfile missing" && exit 1)
    @test -f flake.nix || (echo "❌ flake.nix missing" && exit 1)
    @test -f .gitlab-ci.yml || (echo "❌ .gitlab-ci.yml missing" && exit 1)
    @test -f .gitattributes || (echo "❌ .gitattributes missing" && exit 1)
    @test -f FUNDING.yml || (echo "❌ FUNDING.yml missing" && exit 1)
    @echo "✓ Repository structure validated"
    @echo "✓ RSR Gold standard requirements met"

# Full pre-release validation
pre-release: clean install build test lint validate
    @echo "✓ Pre-release validation complete"
