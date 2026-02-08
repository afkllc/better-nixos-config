{ pkgs, lib, attrs ? {}, webots ? attrs.webots, ... }:

let
    webotsSrc =
    if webots == null then
      lib.throw "Webots source not provided"
    else
      webots;

    dependencies = with pkgs; [
        brotli sndio boost cmake curl dbus expat ffmpeg fox freetype
        gdal gl2ps glew glib gnumake gnupg jdk krb5 libGL libGLU
        libgcrypt libssh2 libuuid libxkbcommon libxml2 libzip
        lsb-release nss_latest pbzip2 pkg-config prelink proj
        python311 readline swig unzip wget xercesc
        xorg.libX11 xorg.libXcomposite xorg.libXtst
        xorg.libxcb xorg.xcbutil xvfb-run zip zlib
    ];

    desktopFile = pkgs.makeDesktopItem {
        name = "webots-fhs";
        exec = "%%EXEC%%";
        icon = "${webotsSrc}/resources/icons/core/webots.png";
        comment = "Webots in an FHS environment";
        desktopName = "Webots (FHS)";
        genericName = "Webots (FHS)";
        categories = [ "Utility" ];
    };
in pkgs.buildFHSEnv rec {
    name = "webots";
    targetPkgs = pkgs: dependencies;

    runScript = pkgs.writeShellScript "webots" ''
        export QT_PLUGIN_PATH=${webotsSrc}/lib/webots/qt/plugins
        export WEBOTS_HOME=${webotsSrc}
        exec ${webotsSrc}/webots "$@"
    '';

    extraInstallCommands = ''
        mkdir -p $out
        cp -r ${desktopFile}/* $out/
        chmod +w $out/share/applications
        sed -i "s#%%EXEC%%#$out/bin/webots#" \
        $out/share/applications/webots-fhs.desktop
    '';

    meta.description = "Webots in an FHS environment";
}