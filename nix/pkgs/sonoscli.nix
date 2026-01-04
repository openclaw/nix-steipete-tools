{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "sonoscli";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/steipete/sonoscli/releases/download/v0.1.0/sonoscli-macos-arm64.tar.gz";
    hash = "sha256-t5VUWXPrxgYXopiQEuO7k91Gx70oefyhbOZmF/XDwaw=";
  };

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
    platforms = [ "aarch64-darwin" ];
    mainProgram = "sonos";
  };
}
