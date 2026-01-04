{
  description = "clawdbot plugin: oracle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    root.url = "path:../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      oracle = root.packages.${system}.oracle;
    in {
      packages.${system}.oracle = oracle;

      clawdbotPlugin = {
        name = "oracle";
        skills = [ ./skills/oracle ];
        packages = [ oracle ];
        needs = {
          stateDirs = [];
          requiredEnv = [];
        };
      };
    };
}
