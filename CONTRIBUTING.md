# Contributing to Julia the Viper

Thank you for your interest in contributing to JtV! This document provides guidelines and information for contributors.

## Code of Conduct

Be respectful, constructive, and professional. We're building something important together.

## How to Contribute

### 1. Report Bugs

**Before submitting**, check if the issue already exists in GitHub Issues.

**When submitting a bug report**, include:
- JtV version (`jtv --version`)
- Operating system
- Minimal code example that reproduces the bug
- Expected vs actual behavior
- Error messages (full stack trace)

### 2. Suggest Features

**Before suggesting**, check:
- Is this a v1 or v2 feature? (See `docs/GRAMMAR_EVOLUTION.md`)
- Has someone else suggested it?
- Does it align with JtV's core mission?

**When suggesting**, provide:
- Clear use case
- Example syntax
- How it preserves security guarantees

### 3. Submit Code

**Getting Started**:
```bash
# Fork the repo
git clone https://github.com/YOUR_USERNAME/julia-the-viper
cd julia-the-viper

# Install dependencies
just install

# Run tests
just test

# Make your changes
git checkout -b feature/my-awesome-feature

# Commit with clear messages
git commit -m "Add feature: Brief description"

# Push and create PR
git push origin feature/my-awesome-feature
```

## Development Setup

### Required Tools
- **Rust** 1.70+ (`rustup`)
- **Deno** (for analyzer)
- **Just** (build tool)
- **Git**

### Optional Tools
- **wasm-pack** (for WASM builds)
- **Lean 4** (for formal proofs, v2)
- **Node.js** (for playground, future)

### Build Commands

```bash
# Build everything
just build

# Build WASM
just build-wasm

# Run tests
just test

# Run benchmarks
just bench

# Format code
just fmt

# Lint code
just lint

# Run example
just example 01_hello_addition
```

## Project Structure

```
julia-the-viper/
├── packages/
│   ├── jtv-lang/        # Core Rust implementation
│   ├── jtv-analyzer/    # TypeScript code analyzer
│   └── jtv-safe/        # Smart contract compiler (future)
├── examples/            # Example programs
├── tools/
│   ├── cli/             # Command-line tool
│   ├── vscode-extension/# VS Code support
│   └── lsp/             # Language server (future)
├── docs/                # Documentation
└── shared/              # Shared resources (grammar, types)
```

## Coding Standards

### Rust

- **Format**: `cargo fmt`
- **Lint**: `cargo clippy -- -D warnings`
- **Tests**: Every PR must include tests
- **Documentation**: Public APIs must have doc comments

Example:
```rust
/// Parses a JtV program from source code.
///
/// # Arguments
/// * `input` - Source code string
///
/// # Returns
/// * `Ok(Program)` - Parsed AST
/// * `Err(JtvError)` - Parse error with details
///
/// # Example
/// ```rust
/// let program = parse_program("x = 5 + 3")?;
/// ```
pub fn parse_program(input: &str) -> Result<Program> {
    // ...
}
```

### TypeScript/Deno

- **Format**: `deno fmt`
- **Lint**: `deno lint`
- **Type annotations**: Always use explicit types
- **Tests**: `deno test`

### JtV Code

- **Style**: Follow examples in `examples/`
- **Comments**: Explain non-obvious logic
- **Pure functions**: Mark with `@pure` when applicable

## Testing Guidelines

### Unit Tests

Test individual functions in isolation:

```rust
#[test]
fn test_parse_addition() {
    let code = "x = 5 + 3";
    let result = parse_program(code);
    assert!(result.is_ok());
}
```

### Integration Tests

Test complete workflows:

```rust
#[test]
fn test_fibonacci_execution() {
    let code = r#"
        fn fibonacci(n: Int): Int { ... }
        result = fibonacci(10)
    "#;

    let program = parse_program(code).unwrap();
    let mut interpreter = Interpreter::new();
    interpreter.run(&program).unwrap();

    let result = interpreter.get_variable("result").unwrap();
    assert_eq!(result, Value::Int(55));
}
```

### Benchmark Tests

Compare performance:

```rust
fn parse_benchmark(c: &mut Criterion) {
    c.bench_function("parse complex program", |b| {
        b.iter(|| parse_program(black_box(COMPLEX_CODE)));
    });
}
```

## Documentation

### Code Comments

- **When**: Non-obvious logic, algorithms, security properties
- **Format**: Clear, concise, no redundancy
- **Example**:

```rust
// Use Babylonian method for fast integer square root
// Guaranteed to converge in log(n) iterations
fn sqrt(n: Int) -> Int { ... }
```

### Doc Comments (Rust)

Required for all public APIs:

```rust
/// Brief one-line description.
///
/// Longer explanation if needed.
///
/// # Arguments
/// * `param1` - Description
///
/// # Returns
/// Description of return value
///
/// # Errors
/// When and why errors occur
///
/// # Examples
/// ```
/// // Working code example
/// ```
pub fn function_name(...) { ... }
```

### Documentation Files

- **README**: Keep concise, link to detailed docs
- **Guides**: Step-by-step tutorials
- **References**: Complete API documentation
- **Architecture**: Design decisions and rationale

## Pull Request Process

### Before Submitting

- [ ] Code compiles without warnings
- [ ] All tests pass (`just test`)
- [ ] Code is formatted (`just fmt`)
- [ ] Linter passes (`just lint`)
- [ ] New code has tests
- [ ] Documentation updated

### PR Description Template

```markdown
## Summary
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- Bullet list of modifications
- Be specific

## Testing
How was this tested?

## Breaking Changes
Any backward-incompatible changes?

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Changelog entry (if applicable)
```

### Review Process

1. **Automated checks** must pass (CI/CD)
2. **Maintainer review** (usually within 48 hours)
3. **Feedback addressed** by contributor
4. **Final approval** and merge

## Priority Areas

We especially welcome contributions in these areas:

### High Priority
1. **WASM code generation** - Core functionality
2. **Benchmarking** - Validate performance claims
3. **Error messages** - Improve user experience
4. **Examples** - More real-world use cases

### Medium Priority
5. **LSP server** - Editor support
6. **Standard library** - More utilities
7. **Documentation** - Tutorials, guides
8. **Tooling** - Debugger, formatter

### Low Priority (v2)
9. **Reversible computing** - Specification complete, implementation pending
10. **Formal proofs** - Lean 4 integration
11. **Quantum algorithms** - After v1 is stable

## Communication

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: General questions, ideas
- **Pull Requests**: Code contributions
- **Email**: For sensitive issues

## Recognition

Contributors are recognized in:
- `CONTRIBUTORS.md` (alphabetical)
- Release notes (for significant contributions)
- Project documentation (for major features)

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 License.

## Questions?

Not sure where to start? Open a GitHub Discussion with the "question" tag.

Thank you for helping make JtV better! 🐍
