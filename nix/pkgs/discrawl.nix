{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.13.4/discrawl_0.13.4_darwin_arm64.tar.gz";
      hash = "sha256-q+B24eSMiZ6lyo1arEyFb8xPVCWwyiR5+5NSLETVWFQ=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.13.4/discrawl_0.13.4_linux_amd64.tar.gz";
      hash = "sha256-T6stbE4BTwnr0JrSBTWTJrSwcuZLGST4wyuv9H7DVgk=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.13.4/discrawl_0.13.4_linux_arm64.tar.gz";
      hash = "sha256-Y1qAkE+7MFvaTXECy7tfr7nT8e86vLEx0FG1MvDYnLg=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.13.4";

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
