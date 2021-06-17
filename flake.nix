{
  description = "Rust projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, naersk, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      rec {
        # `nix develop`
        devShell = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              rust-bin.stable.latest.default
              cargo-watch
              rust-analyzer

              nixpkgs-fmt
            ] ++ lib.optionals stdenv.isDarwin
              (with darwin.apple_sdk.frameworks; [ libiconv Security ]);

            shellHook = ''
              export PATH=$PATH:$HOME/.cargo/bin
            '';

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          };
      }
    );
}
