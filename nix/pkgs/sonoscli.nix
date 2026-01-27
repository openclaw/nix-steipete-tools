{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.1.0/sonoscli-macos-arm64.tar.gz";
      hash = "sha256-t5VUWXPrxgYXopiQEuO7k91Gx70oefyhbOZmF/XDwaw=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.1.0/sonoscli_0.1.0_linux_amd64.tar.gz";
      hash = "sha256-8g/sTD4P8Ctbpv5N0nZ1SpP+UH6CUuUwNEo4VjW01ZM=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.1.0/sonoscli_0.1.0_linux_arm64.tar.gz";
      hash = "sha256-EtBtsNcvD5OvryUjCQ5oy3H7w4etgfXs7PkdsefWdE0=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sonoscli";
  version = "0.1.0";

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
