{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/Peekaboo/releases/download/v3.0.0-beta3/peekaboo-macos-universal.tar.gz";
      hash = "sha256-d+rfb9XFTqxktIRNXMiHiQttb0XUmvYbBcbinqLL0kU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "peekaboo";
  version = "3.0.0-beta3";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp $(find . -type f -name peekaboo | head -1) "$out/bin/peekaboo"
    chmod 0755 "$out/bin/peekaboo"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Lightning-fast macOS screenshots & AI vision analysis";
    homepage = "https://github.com/steipete/peekaboo";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "peekaboo";
  };
}
