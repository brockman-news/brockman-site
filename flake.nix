{
  description = "Website for brockman";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs }: let
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
        src = ./.;
        installPhase = ''
          mkdir -p $out
          cp -r $src/{terminal.css,index.html,bots.html} $out/
        '';
      };
    };

    packages = forAllSystems (system: {
      default = (pkgsForSystem system).brockman-site;
    });
  };
}
