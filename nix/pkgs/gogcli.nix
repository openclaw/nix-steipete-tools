{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/steipete/gogcli/releases/download/v0.4.2/gogcli_0.4.2_darwin_arm64.tar.gz";
    hash = "sha256-RC08Z/iBORPv/1Amt7nONFEj9j6OXkXN0RsDNuR8qBM=";
  };

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
    platforms = [ "aarch64-darwin" ];
    mainProgram = "gog";
  };
}
