{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.10/wacrawl_0.3.10_darwin_arm64.tar.gz";
      hash = "sha256-rkL2LJV+/OWh4GSMeWgk7jgw32EWqWw/5pE8+lZhbPU=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.10/wacrawl_0.3.10_linux_amd64.tar.gz";
      hash = "sha256-btw4hWJ2QEzI3MR971o8KVCyXR75Jn6vWQNxTsB7dc0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.10/wacrawl_0.3.10_linux_arm64.tar.gz";
      hash = "sha256-KFhqlD9Z67z27q1L+2TNVJLMuJ9sCpr0CpMzXRncUlU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.3.10";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/wacrawl"
    cp $(find . -type f -name wacrawl | head -1) "$out/bin/wacrawl"
    chmod 0755 "$out/bin/wacrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/wacrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/wacrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Read-only local archive and search for WhatsApp Desktop data";
    homepage = "https://github.com/steipete/wacrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "wacrawl";
  };
}
