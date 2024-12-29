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
  in {
    devShells = forAllSystems (system: let pkgs = nixpkgs.legacyPackages.${system}; in {
      default = pkgs.mkShell {
        packages = [ pkgs.zola ];
      };
    });

    packages = forAllSystems (system: let pkgs = nixpkgs.legacyPackages.${system}; in rec {
      brockman-news-site = pkgs.stdenv.mkDerivation {
        name = "brockman-news-site";
        src = pkgs.symlinkJoin {
          name = "zola-source";
          paths = [
            ./.
            (pkgs.runCommand "theme" {} ''mkdir -p $out/themes && cp -r ${theme-terminimal.outPath} $out/themes/terminimal'')
          ];
        };
        buildPhase = ''
          ${pkgs.zola}/bin/zola build
        '';
        installPhase = ''
          mkdir $out
          cp -r public/* $out/
        '';
      };
      default = brockman-news-site;
    });
  };
}
