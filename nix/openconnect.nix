#Source: https://github.com/active-group/openconnect-sso/blob/master/nix/openconnect.nix
{
  lib,
  stdenv,
  fetchFromGitLab,
  pkg-config,
  autoreconfHook,
  gnutls,
  p11-kit,
  openssl,
  useOpenSSL ? false,
  gmp,
  libxml2,
  stoken,
  zlib,
  pcsclite,
  vpnc-scripts,
  xdg-utils,
  useDefaultExternalBrowser ?
    stdenv.hostPlatform.isLinux && stdenv.buildPlatform == stdenv.hostPlatform,
}:

stdenv.mkDerivation {
  pname = "openconnect";
  version = "9.21";

  src = fetchFromGitLab {
    owner = "openconnect";
    repo = "openconnect";
    rev = "8b702bf2dbaf11302ed98629214b1df5d50a12aa";
    hash = "sha256-Jtd4cIR6BWSQPmLm8UOvlEcC1g6QlMgFw/aM7cokOCw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  configureFlags = [
    "--with-vpnc-script=${vpnc-scripts}/bin/vpnc-script"
    "--disable-nls"
    "--without-openssl-version-check"
  ];

  buildInputs = [
    gmp
    libxml2
    stoken
    zlib
    (if useOpenSSL then openssl else gnutls)
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    p11-kit
    pcsclite
  ]
  ++ lib.optional useDefaultExternalBrowser xdg-utils;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];
  meta = {
    description = "VPN Client for Cisco's AnyConnect SSL VPN";
    homepage = "https://www.infradead.org/openconnect/";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [
      tricktron
      pentane
    ];
    platforms = lib.platforms.unix;
    mainProgram = "openconnect";
  };
}
