{
  description = "cockpit-project/cockpit-podman app";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        #"aarch64-linux"
        #"x86_64-darwin"
        #"aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f  {
        pkgs = import nixpkgs { inherit system; };
      });

    in
    {
      packages = forAllSystems ({ pkgs }: {

        default = pkgs.stdenv.mkDerivation rec {        
          name = "cockpit-podman";
          src = self;

          nativeBuildInputs = with pkgs; [
            cockpit
            podman
            gettext
            nodejs
            git
            gawk
          ];

          makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

          postPatch = ''
            substituteInPlace Makefile --replace-quiet /usr/local/share $out/share

            mkdir -p pkg/lib
            mkdir -p dist
            
            touch pkg/lib/cockpit-po-plugin.js
            touch dist/manifest.json
          '';

          dontBuild = true;
 
        };
      });
    };
}
