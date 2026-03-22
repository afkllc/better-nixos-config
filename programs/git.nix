{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        gh
    ];
    programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-qt;
        enableSSHSupport = true;
    };
    programs.git = {
        enable = true;
        prompt.enable = true;
        config = {
        commit.gpgsign = true;
        tag.gpgsign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        init.defaultBranch = "main";
        pull.rebase = false;
        "credential \"https://github.com\"" = {
            helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
        "credential \"https://gist.github.com\"" = {
            helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
        };
    };
}
