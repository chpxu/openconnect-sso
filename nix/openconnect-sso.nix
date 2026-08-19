{
  wrapQtAppsHook,
  pkgs,
  lib,
  openconnect,
  ...
}:
let
  dependencies = with pkgs.python314Packages; [
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
    pysocks
    pyqt6
    pyqt6-webengine
    pyotp
    urllib3
    setuptools
  ];
in
pkgs.python314.pkgs.buildPythonApplication rec {
  inherit dependencies;
  pname = "openconnect-sso";
  version = "0.8.0";
  src = pkgs.lib.cleanSource ../.;
  # format = "pyproject";
  pyproject = true;
  doCheck = true;
  buildInputs = [
    (pkgs.python314.withPackages (python-pkgs: dependencies))
    wrapQtAppsHook
  ];
  propagatedBuildInputs = [
    openconnect
  ]
  ++ lib.optional (pkgs.stdenv.isLinux) pkgs.qt6Packages.qtwayland;
  # ++ dependencies;
  preFixup = ''
    makeWrapperArgs+=(
      # Force the app to use QT_PLUGIN_PATH values from wrapper
      --unset QT_PLUGIN_PATH
      "''${qtWrapperArgs[@]}"
      # avoid persistant warning on starup
      --set QT_STYLE_OVERRIDE Fusion
    )
  '';
  # propagatedBuildInputs = with pkgs.python312Packages; [ hatchling ] ++ [ pkgs.hatch ];
  nativeBuildInputs = [
    pkgs.python314Packages.pyqt6
    wrapQtAppsHook
  ];
  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  # preferWheels = true;
  build-system = with pkgs.python314Packages; [
    hatchling
    hatch
  ];
  # postInstall = ''
  #   rm -rf $out/bin
  #   mkdir -p $out/bin
  #   ls $out/bin
  #   ${pkgs.makeWrapper} ${pkgs.python312}/bin/python3 $out/bin/openconnect-sso \
  #   -add-flags "-m opeconnect_sso.cli"
  # '';
  meta = {
    mainProgram = "openconnect-sso";
  };
  # overrides = [
  #   poetry2nix.defaultPoetryOverrides
  #   (
  #     self: super: {
  #       inherit (python3Packages) cryptography pyqt6 pyqt6-sip pyqt6-webengine six more-itertools;
  #     }
  #   )
  # ];
}
