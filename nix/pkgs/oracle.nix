{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, nodejs
, pnpm
, python3
, python3Packages
, pkg-config
, makeWrapper
, pkgs
, zstd
}:

let
  pnpmFetchDepsPkg = pkgs.callPackage "${pkgs.path}/pkgs/build-support/node/fetch-pnpm-deps" {
    inherit pnpm;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "oracle";
  version = "0.8.5";

  srcTarball = fetchurl {
    url = "https://github.com/steipete/oracle/releases/download/v0.8.5/oracle-0.8.5.tgz";
    hash = "sha256-MSb1+5wEHK38iq+yob7Tz7xov0Wh9zHcmXGs/l2KdMA=";
  };

  lockSrc = fetchFromGitHub {
    owner = "steipete";
    repo = "oracle";
    rev = "v0.8.5";
    hash = "sha256-q1l3IcVAj7Gb8Lp0JzQakLRg2AlVrJniMBHRwxKQVbM=";
  };

  srcPatched = stdenv.mkDerivation {
    name = "oracle-src-patched";
    src = finalAttrs.srcTarball;
    nativeBuildInputs = [ python3 ];
    dontConfigure = true;
    dontBuild = true;
    unpackPhase = ''
      tar -xzf "$src"
    '';
    installPhase = ''
      mkdir -p "$out"
      if [ -d package ]; then
        shopt -s dotglob
        mv package/* "$out"/
      else
        cp -R . "$out"/
      fi
      cp -f "${finalAttrs.lockSrc}/pnpm-lock.yaml" "$out/pnpm-lock.yaml"
      export OUT_DIR="$out"
      python3 - <<'PY'
import json
import os
from pathlib import Path

path = Path(os.environ["OUT_DIR"]) / "package.json"
data = json.loads(path.read_text())
data.pop("packageManager", None)
path.write_text(json.dumps(data, indent=2) + "\n")
PY
    '';
  };

  src = finalAttrs.srcPatched;

  pnpmDeps = (pnpmFetchDepsPkg.fetchPnpmDeps {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    src = finalAttrs.srcPatched;
    hash = "sha256-Tmwe55l4QMzXsO7F1kUSnGuZjkuMtDORNtqKnWZ/HrA=";
    fetcherVersion = 3;
  });

  nativeBuildInputs = [
    nodejs
    pnpm
    python3
    python3Packages.setuptools
    pkg-config
    makeWrapper
    zstd
  ];

  env = {
    PNPM_IGNORE_PACKAGE_MANAGER_CHECK = "1";
    CI = "1";
    HOME = "/tmp";
    PNPM_HOME = "/tmp/pnpm-home";
    PNPM_CONFIG_HOME = "/tmp/pnpm-config";
    XDG_CACHE_HOME = "/tmp/pnpm-cache";
    NPM_CONFIG_USERCONFIG = "/tmp/pnpm-config/.npmrc";
    npm_config_nodedir = "${nodejs.dev}";
    npm_config_build_from_source = "1";
    PNPM_CONFIG_IGNORE_SCRIPTS = "1";
  };

  buildPhase = ''
    runHook preBuild
    mkdir -p "$HOME" "$PNPM_HOME" "$PNPM_CONFIG_HOME" "$XDG_CACHE_HOME"
    export PNPM_STORE_PATH="$TMPDIR/pnpm-store"
    mkdir -p "$PNPM_STORE_PATH"
    tar --zstd -xf ${finalAttrs.pnpmDeps}/pnpm-store.tar.zst -C "$PNPM_STORE_PATH"
    pnpm install --offline --no-frozen-lockfile --store-dir "$PNPM_STORE_PATH" --ignore-scripts
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec" "$out/bin"
    cp -r dist package.json vendor assets-oracle-icon.png node_modules "$out/libexec/"
    find "$out/libexec/node_modules" -name ".pnpm-workspace-state-v1.json" -delete
    chmod 0755 "$out/libexec/dist/bin/oracle-cli.js" "$out/libexec/dist/bin/oracle-mcp.js"
    ln -s "$out/libexec/dist/bin/oracle-cli.js" "$out/bin/oracle"
    ln -s "$out/libexec/dist/bin/oracle-mcp.js" "$out/bin/oracle-mcp"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Bundle prompts + files for second-model review";
    homepage = "https://github.com/steipete/oracle";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "oracle";
  };
})
