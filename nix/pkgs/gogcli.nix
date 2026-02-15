{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.10.0/gogcli_0.10.0_darwin_arm64.tar.gz";
      hash = "sha256-sNPDBSmr40X1Epzm7ZRzJfcDHU7p70kLHl12/5c4/J8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.10.0/gogcli_0.10.0_linux_amd64.tar.gz";
      hash = "sha256-f8DVB7LQprzprE6IyGu3jZo2ckRXEu9FiomMM7KqIV0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.10.0/gogcli_0.10.0_linux_arm64.tar.gz";
      hash = "sha256-Q48xgr47bF3Om3kyKm6tnH9nOW9g0Em7i0o5AEhPZRU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.10.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp gog "$out/bin/gog"
    chmod 0755 "$out/bin/gog"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Google CLI for Gmail, Calendar, Drive, and Contacts";
    homepage = "https://github.com/steipete/gogcli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "gog";
  };
}
