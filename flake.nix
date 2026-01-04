{
  description = "Nix packaging for steipete tools (clawdbot)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          summarize = pkgs.callPackage ./nix/pkgs/summarize.nix {};
          gogcli = pkgs.callPackage ./nix/pkgs/gogcli.nix {};
        }
      );

      checks = forAllSystems (system: {
        summarize = self.packages.${system}.summarize;
        gogcli = self.packages.${system}.gogcli;
      });
    };
}
