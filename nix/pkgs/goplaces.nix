{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.9/goplaces_0.4.9_darwin_arm64.tar.gz";
      hash = "sha256-jBM4gN9mUQF3fPtuOV8TNlIYcJgMGGZYQHbp2yl4JQo=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.9/goplaces_0.4.9_darwin_amd64.tar.gz";
      hash = "sha256-Na1OYxMG8WVLO7X6oTBnwctN/Pxicddf9R1Vq+oaKI4=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.9/goplaces_0.4.9_linux_amd64.tar.gz";
      hash = "sha256-59XbSSfC2ozEQwFhIKAv3YBiORZEcVst8y94cHIupKw=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.9/goplaces_0.4.9_linux_arm64.tar.gz";
      hash = "sha256-qD4cBhL38Yv8k8sqwRdLVTYJwvYVmulwN986EqNipOE=";
    };
  };

  meta = with lib; {
    description = "Modern Go client + CLI for the Google Places API (New)";
    homepage = "https://github.com/openclaw/goplaces";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "goplaces";
  };

in
stdenv.mkDerivation {
  pname = "goplaces";
  version = "0.4.9";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/goplaces"
    cp $(find . -type f -name goplaces | head -1) "$out/bin/goplaces"
    chmod 0755 "$out/bin/goplaces"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/goplaces/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/goplaces/"
    fi
    runHook postInstall
  '';

  inherit meta;
}
