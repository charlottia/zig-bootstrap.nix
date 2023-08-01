{
  pkgs,
  zbVersion,
  zigVersion,
  triple,
  cpu,
}: let
  mkStageDerivation = number:
    pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "zb-stage${toString number}";
      version = zbVersion;

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
        mkdir out
        TARGET="${triple}"
        MCPU="${cpu}"
        ${builtins.readFile ./build-common}
        ${finalAttrs.stageBuild}
        cd "$ROOTDIR"
      '';

      stageBuild = null;
    });
in rec {
  stage-1 = (mkStageDerivation 1).overrideAttrs {
    stageBuild = builtins.readFile ./build-1;

    installPhase = ''
      mkdir -p $out
      cp -a out/host $out
    '';
  };

  stage-2 = (mkStageDerivation 2).overrideAttrs (finalAttrs: previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++
    [stage-1];

    CMAKE_GENERATOR = "Unix Makefile";

    stageBuild = ''
      cp -a ${stage-1}/host out
      chmod -R u+w out
      ${builtins.readFile ./build-2}
    '';

    installPhase = ''
      mkdir -p $out
      cp -r out/host $out
    '';
  });
}
