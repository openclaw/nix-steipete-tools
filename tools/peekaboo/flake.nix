{
  description = "clawdbot plugin: peekaboo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    root.url = "path:../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      peekaboo = root.packages.${system}.peekaboo;
    in {
      packages.${system}.peekaboo = peekaboo;

      clawdbotPlugin = {
        name = "peekaboo";
        skills = [ ./skills/peekaboo ];
        packages = [ peekaboo ];
        needs = {
          stateDirs = [];
          requiredEnv = [];
        };
      };
    };
}
