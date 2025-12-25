{
  wrapQtAppsHook,
  pkgs,
  ...
}:
let dependencies = with pkgs.python312Packages; [
    attrs
    colorama
    importlib-metadata
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
  ];
  in
pkgs.python312.pkgs.buildPythonApplication rec {
  inherit dependencies;
  pname = "openconnect-sso";
  version = "0.8.0";
  src = pkgs.lib.cleanSource ../.;
  # format = "pyproject";
  pyproject = true;
  doCheck = true;
  buildInputs = [
    pkgs.hatch
    wrapQtAppsHook
  ]
  ++ dependencies;
  propagatedBuildInputs = with pkgs.python312Packages; [ hatchling] ++ [pkgs.hatch];

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  # preferWheels = true;
  build-system = with pkgs.python312Packages; [
    hatchling
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
