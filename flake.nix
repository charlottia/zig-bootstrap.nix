{
  description = "Zig via bootstrapped LLVM";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    systemTriples = {
      "x86_64-linux" = "x86_64-linux-gnu";
      "x86_64-darwin" = "x86_64-macos-none";
      "aarch64-linux" = "aarch64-linux-gnu";
      "aarch64-darwin" = "aarch64-macos-none";
    };

    zbVersion = "8efff94f39e147b54ee2d5bce939b998f02d4f76";
    zigVersion = "0.11.0-dev.4183+32a175740";

    outputs = flake-utils.lib.eachSystem (builtins.attrNames systemTriples) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      triple = systemTriples.${system};
      cpu = "baseline";
      stages = import ./stages.nix {inherit pkgs zbVersion zigVersion triple cpu;};
    in {
      formatter = pkgs.alejandra;

      packages = {
        default = pkgs.stdenv.mkDerivation {
          pname = "zig";
          version = zigVersion;

          dontUnpack = true;

          nativeBuildInputs = [
            stages.stage-2
          ];
        };
      };
    });
  in
    outputs;
}
