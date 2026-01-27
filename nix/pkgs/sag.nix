{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sag/releases/download/v0.2.2/sag_0.2.2_darwin_universal.tar.gz";
      hash = "sha256-BVS675EiF9nh85iPttdJLUbS9JEFpeuRdeP4YfOc0ok=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sag/releases/download/v0.2.2/sag_0.2.2_linux_amd64.tar.gz";
      hash = "sha256-/d/iVTZI/ZzTRGYQxVF22JeFDXn0qpXWC2BdOH/6vcg=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sag";
  version = "0.2.2";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp sag "$out/bin/sag"
    chmod 0755 "$out/bin/sag"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line ElevenLabs TTS with mac-style flags";
    homepage = "https://github.com/steipete/sag";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "sag";
  };
}
