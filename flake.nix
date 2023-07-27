{
  description = "Zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in rec {
      packages = {
        default = pkgs.stdenv.mkDerivation rec {
          pname = "zig";
          version = "0.11.0.dev1+g${lib.substring 0 7 src.rev}";
          src = pkgs.fetchFromGitHub {
            owner = "ziglang";
            repo = "zig";
            rev = "1aacfa7186187ed467a5e3189a877493d5c620a1";
            sha256 = "rhFKbY2XeFb5ErLAC0XBzQLQsIxelb0Ydgwse1THF30=";
          };

          nativeBuildInputs = with pkgs; [
            cmake
            clang_16
            llvmPackages_16.clang-unwrapped
            lld_16
            llvmPackages_16.libllvm
            mold
          ];

          buildInputs = with pkgs; [
            libxml2
          ];
        };
      };
      formatter = pkgs.alejandra;
    });
  in
    outputs;
}
