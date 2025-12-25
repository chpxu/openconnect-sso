{
  wrapQtAppsHook,
  pkgs,
  ...
}:

pkgs.python312.pkgs.buildPythonApplication rec {
  pname = "openconnect-sso";
  version = "0.8.0";
  src = pkgs.lib.cleanSource ../.;
  pyproject = true;
  doCheck = false;
  buildInputs = [
    pkgs.hatch
    wrapQtAppsHook
  ]
  ++ (with pkgs.python312Packages; [
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
  ]);
  propagatedBuildInputs = with pkgs.python312Packages; [ setuptools ];

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  # preferWheels = true;
  build-system = with pkgs.python312Packages; [
    setuptools
    wheel
    hatchling
  ];

  # overrides = [
  #   poetry2nix.defaultPoetryOverrides
  #   (
  #     self: super: {
  #       inherit (python3Packages) cryptography pyqt6 pyqt6-sip pyqt6-webengine six more-itertools;
  #     }
  #   )
  # ];
}
