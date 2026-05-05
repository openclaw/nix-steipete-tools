{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.6.6/discrawl_0.6.6_darwin_arm64.tar.gz";
      hash = "sha256-0E6wsXrmhUCi7QOQ9O9AQTVLqow2V3xtPY5pLu9tblE=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.6.6/discrawl_0.6.6_linux_amd64.tar.gz";
      hash = "sha256-BEfe4Qymqt8284GJI6wqvFPuWAjBoLrAXpUo0XfhXUE=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.6.6/discrawl_0.6.6_linux_arm64.tar.gz";
      hash = "sha256-rEHI1Lt6EZLIedb2w4BGbBDRUa4UMZqmL6nTXQ4Uflw=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.6.6";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/discrawl"
    cp $(find . -type f -name discrawl | head -1) "$out/bin/discrawl"
    chmod 0755 "$out/bin/discrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/discrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/discrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mirror Discord into SQLite and search server history locally";
    homepage = "https://github.com/steipete/discrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "discrawl";
  };
}
