{
  description = "clawdbot plugin: gogcli";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    root.url = "path:../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      gogcli = root.packages.${system}.gogcli;
    in {
      packages.${system}.gogcli = gogcli;

      clawdbotPlugin = {
        name = "gogcli";
        skills = [ ./skills/gogcli ];
        packages = [ gogcli ];
        needs = {
          stateDirs = [];
          requiredEnv = [];
        };
      };
    };
}
