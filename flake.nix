{
  description = "Website for brockman";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs }: let
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
        src = ./.;
        buildPhase = ''
          ${pkgs.zola}/bin/zola build
        '';
        installPhase = ''
          cp -r public/* $out/
        '';
      };
      default = brockman-news-site;
    });
  };
}
