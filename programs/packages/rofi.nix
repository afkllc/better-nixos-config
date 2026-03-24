{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "rofi-wrapper";

  src = pkgs.rofi;

  dontUnpack = true;

  buildInputs = [ pkgs.makeWrapper ];

  buildPhase = ''
    mkdir -p $out/bin
    cp $src/bin/rofi $out/bin/rofi
  '';

  installPhase = ''
    wrapProgram $out/bin/rofi \
      --set XDG_RUNTIME_DIR "/run/user/$UID" \
      --set GNOME_KEYRING_CONTROL "/run/user/$UID/keyring" \
      --set SSH_AUTH_SOCK "/run/user/$UID/keyring/ssh"
  '';
}