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
          camsnap = pkgs.callPackage ./nix/pkgs/camsnap.nix {};
          sonoscli = pkgs.callPackage ./nix/pkgs/sonoscli.nix {};
          bird = pkgs.callPackage ./nix/pkgs/bird.nix {};
          peekaboo = pkgs.callPackage ./nix/pkgs/peekaboo.nix {};
          poltergeist = pkgs.callPackage ./nix/pkgs/poltergeist.nix {};
          sag = pkgs.callPackage ./nix/pkgs/sag.nix {};
          imsg = pkgs.callPackage ./nix/pkgs/imsg.nix {};
          oracle = pkgs.callPackage ./nix/pkgs/oracle.nix {
            pkgs = pkgs;
            pnpm = if pkgs ? pnpm_10 then pkgs.pnpm_10 else pkgs.pnpm;
          };
        }
      );

      checks = forAllSystems (system: {
        summarize = self.packages.${system}.summarize;
        gogcli = self.packages.${system}.gogcli;
        camsnap = self.packages.${system}.camsnap;
        sonoscli = self.packages.${system}.sonoscli;
        bird = self.packages.${system}.bird;
        peekaboo = self.packages.${system}.peekaboo;
        poltergeist = self.packages.${system}.poltergeist;
        sag = self.packages.${system}.sag;
        imsg = self.packages.${system}.imsg;
        oracle = self.packages.${system}.oracle;
      });
    };
}
