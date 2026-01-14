{ lib
, stdenv
, fetchurl
, nodejs
, pnpm
, python3
, python3Packages
, pkg-config
, makeWrapper
, jq
, pkgs
, zstd
}:

let
  pname = "summarize";
  version = "0.9.0";
  binSources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/summarize/releases/download/v0.9.0/summarize-macos-arm64-v0.9.0.tar.gz";
      hash = "sha256-B6/eUcbv4K9kgozo1fELFX+NNGa0C64dB6OSydwu6A8=";
    };
  };

  src = fetchurl {
    url = "https://github.com/steipete/summarize/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-HQ/jboAN+g7Mz41ayDAt0thR5kuJjttgfJTXE7IRSzQ=";
  };

  pnpmFetchDepsPkg = pkgs.callPackage "${pkgs.path}/pkgs/build-support/node/fetch-pnpm-deps" {
    inherit pnpm;
  };

  pnpmDeps = (pnpmFetchDepsPkg.fetchPnpmDeps {
    pname = pname;
    version = version;
    src = src;
    hash = "sha256-3BRbu9xNYUpsUkC1DKXKl8iv5GO9rZqE2eqRVDh8DTA=";
    fetcherVersion = 3;
  });

  meta = with lib; {
    description = "Link → clean text → summary";
    homepage = "https://github.com/steipete/summarize";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "summarize";
  };
in
if stdenv.isLinux then
  stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [
      nodejs
      pnpm
      python3
      python3Packages.setuptools
      pkg-config
      makeWrapper
      jq
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
      PNPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    };

    postPatch = ''
      if [ -f package.json ]; then
        jq 'del(.packageManager)' package.json > package.json.next
        mv package.json.next package.json
      fi
    '';

    buildPhase = ''
      runHook preBuild
      mkdir -p "$HOME" "$PNPM_HOME" "$PNPM_CONFIG_HOME" "$XDG_CACHE_HOME"
      export PNPM_STORE_PATH="$TMPDIR/pnpm-store"
      mkdir -p "$PNPM_STORE_PATH"
      tar --zstd -xf ${pnpmDeps}/pnpm-store.tar.zst -C "$PNPM_STORE_PATH"
      pnpm install --offline --frozen-lockfile --store-dir "$PNPM_STORE_PATH" --ignore-scripts
      pnpm build
      pnpm prune --prod
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/libexec" "$out/bin"
      cp -r dist package.json node_modules "$out/libexec/"
      chmod 0755 "$out/libexec/dist/cli.js"
      makeWrapper "${nodejs}/bin/node" "$out/bin/summarize" \
        --add-flags "$out/libexec/dist/cli.js"
      runHook postInstall
    '';
  }
else
  stdenv.mkDerivation {
    pname = pname;
    version = version;
    src = fetchurl binSources.${stdenv.hostPlatform.system};

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      tar -xzf "$src"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cp summarize "$out/bin/summarize"
      chmod 0755 "$out/bin/summarize"
      runHook postInstall
    '';

    inherit meta;
  }
