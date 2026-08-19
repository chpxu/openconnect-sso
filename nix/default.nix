{
  sources ? import ./sources.nix,
  pkgs,
}:

let
  inherit (pkgs) python314Packages qt6;
  openconnect = pkgs.callPackage ./openconnect.nix { };
  openconnect-sso = qt6.callPackage ./openconnect-sso.nix { inherit openconnect; };

  shell = pkgs.mkShell {
    buildInputs =
      with pkgs;
      [
        # For Makefile
        gawk
        git
        gnumake
        which
        nixpkgs-fmt # To format Nix source files
      ]
      ++ (with python314Packages; [
        pre-commit # To check coding style during commit
      ])
      ++ (
        # only install those dependencies in the shell env which are meant to be
        # visible in the environment after installation of the actual package.
        # Specifying `inputsFrom = [ openconnect-sso ]` introduces weird errors as
        # it brings transitive dependencies into scope.
        openconnect-sso.propagatedBuildInputs
      );

    shellHook = ''
      # Python wheels are ZIP files which cannot contain timestamps prior to
      # 1980
      export SOURCE_DATE_EPOCH=315532800
      # Helper for tests to find Qt libraries
      export NIX_QTWRAPPER=${qtwrapper}/bin/wrap-qt

      echo "Run 'make help' for available commands"
    '';
  };

  qtwrapper = pkgs.stdenv.mkDerivation {
    name = "qtwrapper";
    dontWrapQtApps = true;
    makeWrapperArgs = [ "\${qtWrapperArgs[@]}" ];
    unpackPhase = ":";
    nativeBuildInputs = with qt6; [
      wrapQtAppsHook
      qtbase
    ];
    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/wrap-qt <<'EOF'
      #!/bin/sh
      "$@"
      EOF
      chmod +x $out/bin/wrap-qt
      wrapQtApp $out/bin/wrap-qt
    '';
  };
in
{
  inherit openconnect-sso shell;
}
