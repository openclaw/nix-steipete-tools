{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.2.0/sonoscli_0.2.0_darwin_arm64.tar.gz";
      hash = "sha256-aXmXlnwHdw91acP0N6NMsP+5dKYlLj9FwBexMtHjsUk=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.2.0/sonoscli_0.2.0_linux_amd64.tar.gz";
      hash = "sha256-EcVWk21CEslv62jen3GyQinCsMYLDklLm/W2g8z0Hg4=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.2.0/sonoscli_0.2.0_linux_arm64.tar.gz";
      hash = "sha256-1nRMOTHIiTX3Rt+RZ4wcCd+/+eWLMo8LQcB62HD78xw=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sonoscli";
  version = "0.2.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/sonoscli"
    cp $(find . -type f -name sonos | head -1) "$out/bin/sonos"
    chmod 0755 "$out/bin/sonos"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/sonoscli/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/sonoscli/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Control Sonos speakers from the command-line";
    homepage = "https://github.com/steipete/sonoscli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "sonos";
  };
}
