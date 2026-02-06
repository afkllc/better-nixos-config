{ pkgs, webots, ... }:
{
    environment.systemPackages = [
        self.packages.x86_64-linux.webots
    ];
}