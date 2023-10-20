{
  description = "ebeenix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, devshell, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { self', pkgs, system, lib, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.devshell.overlays.default ];
        };
        apps.devshell = self'.devShell.flakeApp;
        devShells.default = import ./devshell.nix { inherit pkgs lib; };
      };
    };
}
