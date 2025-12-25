{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, flake-utils, nixpkgs,pyproject-nix,... }: (flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = import nixpkgs {inherit system;};
      openconnect-sso = (import ./nix { inherit pkgs; }).openconnect-sso;
    in
    {
      packages = { inherit openconnect-sso; };
      defaultPackage = openconnect-sso;
      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.python312 openconnect-sso];
        shellHook = ''
          echo "In Openconnect SSO environment";

        '';
      };
    }
  ) // {
      overlay = import ./overlay.nix;
  });
}
