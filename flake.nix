{
  description = "Emacs frontend for the pi coding agent";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    let
      mkPackage =
        pkgs: epkgs:
        epkgs.trivialBuild {
          pname = "pi-coding-agent";
          version = "2.3.0";
          src = self;
          packageRequires = with epkgs; [
            transient
            md-ts-mode
            markdown-table-wrap
          ];
        };
    in
    {
      lib.mkPackage = mkPackage;

      overlays.default = final: prev: {
        emacsPackagesFor =
          emacs:
          (prev.emacsPackagesFor emacs).overrideScope (_efinal: _eprev: {
            pi-coding-agent = mkPackage final (prev.emacsPackagesFor emacs);
          });
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        epkgs = pkgs.emacsPackagesFor pkgs.emacs;
      in
      {
        packages.default = mkPackage pkgs epkgs;
        packages.pi-coding-agent = self.packages.${system}.default;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            emacs
            gnumake
          ];
        };
      }
    );
}
