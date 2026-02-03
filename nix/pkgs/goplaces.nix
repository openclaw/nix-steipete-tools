{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.2.1/goplaces_0.2.1_darwin_arm64.tar.gz";
      hash = "sha256-haImHN6IS2eAMPd6YusOFreSuRc4e0uxpwrYTJkxle8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.2.1/goplaces_0.2.1_linux_amd64.tar.gz";
      hash = "sha256-oDsFtk+M/NOC3CLCgVpVws15VfY7NQdUMUZgdzTqwW0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.2.1/goplaces_0.2.1_linux_arm64.tar.gz";
      hash = "sha256-3PzBz0/DjOmD86yjQRW9Ak/J50/+NDLpjoByEuatmEU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "goplaces";
  version = "0.2.1";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp $(find . -type f -name goplaces | head -1) "$out/bin/goplaces"
    chmod 0755 "$out/bin/goplaces"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Modern Go client + CLI for the Google Places API";
    homepage = "https://github.com/steipete/goplaces";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "goplaces";
  };
}
