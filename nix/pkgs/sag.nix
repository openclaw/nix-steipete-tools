{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sag/releases/download/v0.3.0/sag_0.3.0_darwin_universal.tar.gz";
      hash = "sha256-6JqfjA09qlBrdLp72NCbk0VNkZ/6zv5U0rXcYohAnxQ=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sag/releases/download/v0.3.0/sag_0.3.0_linux_amd64.tar.gz";
      hash = "sha256-jUwjqeORPphMX3xhX36zy/W/X10PP0wP5Ryz5ggpKX4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sag";
  version = "0.3.0";

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
