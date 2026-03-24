{ pkgs, ... }:

{
    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        interactiveShellInit = ''
            source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
            export XDG_RUNTIME_DIR="/run/user/$UID"
            export GNOME_KEYRING_CONTROL="/run/user/$UID/keyring"
            export SSH_AUTH_SOCK="/run/user/$UID/keyring/ssh"
        '';
        shellAliases = {
            q = "exit";
            ls = "ls --color=tty -A";
        };
    };

    users.defaultUserShell = pkgs.zsh;
}