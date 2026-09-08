{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_darwin_arm64.tar.gz";
      hash = "sha256-OHBipZDUcNCxOxx5yrcsWQi/xCq8XPaCQ78/EvwwrNo=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_linux_amd64.tar.gz";
      hash = "sha256-Q476RguCkfAjKZrS7VYQcBytdQjbiDkgOcCJHiF147E=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_linux_arm64.tar.gz";
      hash = "sha256-fCO0AskjS6R26Es5rG2HVES0fsUWMSqZ6HfhOGuigpU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.39.1";

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
    homepage = "https://github.com/openclaw/gogcli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "gog";
  };
}
