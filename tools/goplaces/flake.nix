{
  description = "openclaw plugin: goplaces";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=16c7794d0a28b5a37904d55bcca36003b9109aaa&narHash=sha256-fFUnEYMla8b7UKjijLnMe%2BoVFOz6HjijGGNS1l7dYaQ%3D";
    root.url = "github:openclaw/nix-openclaw-tools?rev=6352c8247b3b889d7f17bce1f09d6c58fd34932c&narHash=sha256-nfCSSyNU97XpKVPgo6mODBwrVeTOuMCl3i18QuGjpN0=";
  };

  outputs = { self, nixpkgs, root }:
    let
      lib = nixpkgs.lib;
      systems = builtins.attrNames root.packages;
      pluginFor = system:
        let
          packagesForSystem = root.packages.${system} or {};
          goplaces = packagesForSystem.goplaces or null;
        in
          if goplaces == null then null else {
            name = "goplaces";
            skills = [ ./skills/goplaces ];
            packages = [ goplaces ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          goplaces = (root.packages.${system} or {}).goplaces or null;
        in
          if goplaces == null then {}
          else { goplaces = goplaces; }
      );

      openclawPlugin = pluginFor;
    };
}
