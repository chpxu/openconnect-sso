{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      ...
    }:

    (
      flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          openconnect-sso = (import ./nix { inherit pkgs; }).openconnect-sso;
        in
        {
          packages = { inherit openconnect-sso; };
          defaultPackage = openconnect-sso;
          devShells.default = pkgs.mkShell {
            buildInputs = [
              (pkgs.python314.withPackages (
                python-pkgs: with python-pkgs; [
                  attrs
                  colorama
                  importlib-metadata
                  importlib-resources
                  lxml
                  keyring
                  prompt-toolkit
                  pyxdg
                  requests
                  structlog
                  toml
                  setuptools
                  pysocks
                  pyqt6
                  pyqt6-webengine
                  pyotp
                  urllib3
                ]
              ))
              openconnect-sso
            ];
            propagatedBuildInputs = [
              (pkgs.python314.withPackages (python-pkgs: with python-pkgs; [ setuptools ]))
            ];
            shellHook = ''
              echo "In Openconnect SSO environment";

            '';
          };
        }
      )
      // {
        overlay = import ./overlay.nix;
      }
    );
}
