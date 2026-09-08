{ pkgs, nodejs }:

(pkgs.callPackage "${pkgs.path}/pkgs/development/tools/pnpm/generic.nix" {
  inherit nodejs;
  version = "11.25.0";
  hash = "sha512-XN6SW08HX3Jetx+64YpC/+eEUkeJ8ZthxzHLhyHsKKruFg4BqNWvT+2ypCzb8wDv4j2zVrDUoXtNY+EfirfJVg==";
}).overrideAttrs {
  # pnpm 11 no longer bundles reflink addons; remove its Windows helpers.
  preConfigure = ''
    rm -rf dist/vendor
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/libexec"
    cp -R . "$out/libexec/pnpm"
    ln -s "$out/libexec/pnpm/bin/pnpm.mjs" "$out/bin/pnpm"
    ln -s "$out/libexec/pnpm/bin/pnpx.mjs" "$out/bin/pnpx"
    runHook postInstall
  '';
}
