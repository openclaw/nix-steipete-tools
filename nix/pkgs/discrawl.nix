{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_darwin_arm64.tar.gz";
      hash = "sha256-CYjVt+wG+ar2vv9ILJAcTWouRH5Lf9U9IsQjV7LTWLM=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_linux_amd64.tar.gz";
      hash = "sha256-D4AZew2LlHiuh/mNoI0w1S27B2auoJEGfI7uD/r+9A0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_linux_arm64.tar.gz";
      hash = "sha256-xtJzUAmvMwfZlInzgxlkxjB4TsO0mSa95pI+OYn3qR4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.14.0";

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
    homepage = "https://github.com/openclaw/discrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "discrawl";
  };
}
