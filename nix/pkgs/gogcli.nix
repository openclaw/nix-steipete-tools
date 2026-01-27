{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.9.0/gogcli_0.9.0_darwin_arm64.tar.gz";
      hash = "sha256-MyG0h5BwSQ9elXF/DHDTdPRqmB1JMEDELitNvW9iUys=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.9.0/gogcli_0.9.0_linux_amd64.tar.gz";
      hash = "sha256-KCGfSldHizw41bM8/LAPU6WUN4S5bDtH5t2HezhMWhM=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.9.0/gogcli_0.9.0_linux_arm64.tar.gz";
      hash = "sha256-Z6T7l0w0Flxg+37bYT94olqm8KlKkEtr3EZBpAl0P3U=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.9.0";

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
