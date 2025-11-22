{
  description = "Julia the Viper - Harvard Architecture Language";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [ "wasm32-unknown-unknown" ];
        };

        buildInputs = with pkgs; [
          rustToolchain
          pkg-config
          openssl
          just
          deno
          wasm-pack
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;

          shellHook = ''
            echo "Julia the Viper - Development Environment"
            echo "=========================================="
            echo "Rust version: $(rustc --version)"
            echo "Cargo version: $(cargo --version)"
            echo "Just version: $(just --version)"
            echo "Deno version: $(deno --version | head -n1)"
            echo ""
            echo "Quick start:"
            echo "  just build       - Build all packages"
            echo "  just test        - Run tests"
            echo "  just build-wasm  - Build WASM target"
            echo "  just --list      - Show all commands"
          '';
        };

        # Build the JtV language package
        packages = {
          jtv-lang = pkgs.rustPlatform.buildRustPackage {
            pname = "jtv-lang";
            version = "0.1.0";
            src = ./packages/jtv-lang;

            cargoLock = {
              lockFile = ./packages/jtv-lang/Cargo.lock;
            };

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];

            meta = with pkgs.lib; {
              description = "Julia the Viper - Harvard Architecture Language";
              homepage = "https://github.com/Hyperpolymath/julia-the-viper";
              license = with licenses; [ mit gpl3Plus ];
              maintainers = [ ];
            };
          };

          # CLI tool
          jtv-cli = pkgs.rustPlatform.buildRustPackage {
            pname = "jtv";
            version = "0.1.0";
            src = ./tools/cli;

            cargoLock = {
              lockFile = ./tools/cli/Cargo.lock;
            };

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];

            meta = with pkgs.lib; {
              description = "Julia the Viper CLI tool";
              homepage = "https://github.com/Hyperpolymath/julia-the-viper";
              license = with licenses; [ mit gpl3Plus ];
              mainProgram = "jtv";
            };
          };

          default = self.packages.${system}.jtv-cli;
        };

        # Checks (tests)
        checks = {
          jtv-lang-tests = self.packages.${system}.jtv-lang.overrideAttrs (old: {
            checkPhase = ''
              cargo test --all-features
            '';
            doCheck = true;
          });
        };

        # Apps
        apps = {
          jtv = flake-utils.lib.mkApp {
            drv = self.packages.${system}.jtv-cli;
          };
          default = self.apps.${system}.jtv;
        };

        # Formatter
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
