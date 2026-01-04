{
  description = "clawdbot plugin: sonoscli";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    root.url = "path:../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      sonoscli = root.packages.${system}.sonoscli;
    in {
      packages.${system}.sonoscli = sonoscli;

      clawdbotPlugin = {
        name = "sonoscli";
        skills = [ ./skills/sonoscli ];
        packages = [ sonoscli ];
        needs = {
          stateDirs = [];
          requiredEnv = [];
        };
      };
    };
}
