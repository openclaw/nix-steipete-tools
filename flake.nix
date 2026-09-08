{
  description = "Nix packaging for OpenClaw tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
      packageSystems = {
        summarize = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        discrawl = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        wacrawl = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        gogcli = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        goplaces = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        camsnap = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        sonoscli = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        peekaboo = [ "aarch64-darwin" ];
        poltergeist = [ "aarch64-darwin" ];
        sag = [ "aarch64-darwin" "x86_64-linux" ];
        imsg = [ "aarch64-darwin" ];
        qmd = [ "aarch64-darwin" "x86_64-linux" ];
      };
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          supports = name: lib.elem system packageSystems.${name};
        in
          (lib.optionalAttrs (supports "summarize") {
            summarize = pkgs.callPackage ./nix/pkgs/summarize.nix {
              pnpm = pkgs.pnpm_11;
              nodejs = pkgs.nodejs_24;
            };
          })
          // (lib.optionalAttrs (supports "discrawl") {
            discrawl = pkgs.callPackage ./nix/pkgs/discrawl.nix {};
          })
          // (lib.optionalAttrs (supports "wacrawl") {
            wacrawl = pkgs.callPackage ./nix/pkgs/wacrawl.nix {};
          })
          // (lib.optionalAttrs (supports "gogcli") {
            gogcli = pkgs.callPackage ./nix/pkgs/gogcli.nix {};
          })
          // (lib.optionalAttrs (supports "goplaces") {
            goplaces = pkgs.callPackage ./nix/pkgs/goplaces.nix {};
          })
          // (lib.optionalAttrs (supports "camsnap") {
            camsnap = pkgs.callPackage ./nix/pkgs/camsnap.nix {};
          })
          // (lib.optionalAttrs (supports "sonoscli") {
            sonoscli = pkgs.callPackage ./nix/pkgs/sonoscli.nix {};
          })
          // (lib.optionalAttrs (supports "peekaboo") {
            peekaboo = pkgs.callPackage ./nix/pkgs/peekaboo.nix {};
          })
          // (lib.optionalAttrs (supports "poltergeist") {
            poltergeist = pkgs.callPackage ./nix/pkgs/poltergeist.nix {};
          })
          // (lib.optionalAttrs (supports "sag") {
            sag = pkgs.callPackage ./nix/pkgs/sag.nix {};
          })
          // (lib.optionalAttrs (supports "imsg") {
            imsg = pkgs.callPackage ./nix/pkgs/imsg.nix {};
          })
          // (lib.optionalAttrs (supports "qmd") {
            qmd = pkgs.callPackage ./nix/pkgs/qmd.nix {};
          })
      );

      checks = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          packages = self.packages.${system};
        in
          packages
          // (lib.optionalAttrs (packages ? qmd) {
            qmd-smoke = pkgs.callPackage ./nix/checks/qmd-smoke.nix {
              qmd = packages.qmd;
            };
          })
          // (lib.optionalAttrs (packages ? imsg && packages ? peekaboo) {
            macos-runtime-assets = pkgs.callPackage ./nix/checks/macos-runtime-assets.nix {
              inherit (packages) imsg peekaboo;
            };
          })
      );
    };
}
