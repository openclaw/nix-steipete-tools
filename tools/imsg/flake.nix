{
  description = "openclaw plugin: imsg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=16c7794d0a28b5a37904d55bcca36003b9109aaa&narHash=sha256-fFUnEYMla8b7UKjijLnMe%2BoVFOz6HjijGGNS1l7dYaQ%3D";
    root.url = "github:openclaw/nix-openclaw-tools?rev=dbf0a31a57407d9140e32357ea8d0215bd9feed9&narHash=sha256-QkPl/Rgk9DXgaVNhjvHHHjy5e81j+MzcVOouZRdUTLA=";
  };

  outputs = { self, nixpkgs, root }:
    let
      lib = nixpkgs.lib;
      systems = builtins.attrNames root.packages;
      pluginFor = system:
        let
          packagesForSystem = root.packages.${system} or {};
          imsg = packagesForSystem.imsg or null;
        in
          if imsg == null then null else {
            name = "imsg";
            skills = [ ./skills/imsg ];
            packages = [ imsg ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          imsg = (root.packages.${system} or {}).imsg or null;
        in
          if imsg == null then {}
          else { imsg = imsg; }
      );

      openclawPlugin = pluginFor;
    };
}
