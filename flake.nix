{
  description = "Website for brockman";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    theme-terminimal.url = "github:pawroman/zola-theme-terminimal";
    theme-terminimal.flake = false;
  };

  outputs = { self, nixpkgs, theme-terminimal }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsForSystem = system: import nixpkgs {
      inherit system;
      overlays = [self.overlays.default];
    };
  in {
    overlays.default = final: prev: {
      brockman-site = prev.stdenv.mkDerivation {
        name = "brockman-news-site";
        src = prev.symlinkJoin {
          name = "zola-source";
          paths = [
            ./.
            (prev.runCommand "theme" {} ''mkdir -p $out/themes && cp -r ${theme-terminimal.outPath} $out/themes/terminimal'')
          ];
        };
        buildPhase = ''
          ${prev.zola}/bin/zola build
        '';
        installPhase = ''
          mkdir $out
          cp -r public/* $out/
        '';
      };
    };

    devShells = forAllSystems (system: let pkgs = pkgsForSystem system; in {
      default = pkgs.mkShell {
        packages = [ pkgs.zola ];
      };
    });

    packages = forAllSystems (system: {
      default = (pkgsForSystem system).brockman-site;
    });
  };
}
