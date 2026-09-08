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
}
