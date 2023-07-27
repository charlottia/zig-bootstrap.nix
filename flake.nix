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

    outputs = flake-utils.lib.eachSystem (builtins.attrNames systemTriples) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      triple = systemTriples.${system};
      cpu = "baseline";
      lib = pkgs.lib;
    in rec {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          pname = "zig";
          version = "0.11.0-dev.4183+32a175740";

          src = ./src;

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            python311
            git
          ];

          dontUseCmakeConfigure = true;

          CMAKE_GENERATOR = "Ninja";

          buildPhase = ''
            ./build-1 ${triple} ${cpu}
          '';

          installPhase = ''
            cp -r out/host $out
          '';
            #cp -r out/zig-${triple}-${cpu} $out
        };
      };
      formatter = pkgs.alejandra;
    });
  in
    outputs;
}
