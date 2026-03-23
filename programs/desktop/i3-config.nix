{
  pkgs,
  lib,
  config,
  ...
}:

let
  mod = "Mod4";
in
{
  programs.i3blocks = {
    enable = true;
    bars = {
      top = {
        battery = {
          interval = 1;
          command = ''echo "Battery: $(acpi -b | grep -P -o '[0-9]+(?=%)')%"'';
        };
        disk = {
          interval = 1;
          command = ''echo "Disk: $(df -h / | grep / | awk '{print $5}')"'';
        };
        cpu = {
          interval = 1;
          command = ''echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{printf "%.1f%%\n", $2 + $4}')"'';
        };
        memory = {
          interval = 1;
          command = ''echo "Memory: $(free -h | grep Mem | awk '{print $3}')"'';
        };
        volume = {
          interval = 0.5;
          command = ''echo "Volume: $(pactl list sinks | grep Volume | head -n1 | awk '{print $5}')"'';
        };
        user = {
          interval = "persistent";
          command = ''echo "User: $(whoami)"'';
        };
        time_date = {
          interval = 1;
          command = ''date +" %a, %d %b - %H:%M:%S"'';
        };
      };
    };
  };
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      fonts = {
        names = [ "FiraCode" ];
        size = 10.0;
      };
      keybindings = lib.mkOptionDefault {
        # Basic Keybinds
        "${mod}+d" = "exec --no-startup-id rofi -show drun";
        "${mod}+shift+d" = "exec --no-startup-id rofi -show window";

        "${mod}+Shift+x" = "exec --no-startup-id i3lock-fancy";
        "${mod}+Return" = "exec xfce4-terminal";

        # Focus
        "${mod}+j" = "focus left";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus down";
        "${mod}+semicolon" = "focus right";

        # Move
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move down";
        "${mod}+Shift+semicolon" = "move right";
        
        # Audio
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";

        # Screen Brightness
        "XF86MonBrightnessUp" = "exec xbacklight -inc 20";
        "XF86MonBrightnessDown" = "exec xbacklight -dec 20";
      };
      bars = [
        {
          position = "top";
          statusCommand = "i3blocks -c $HOME/.config/i3blocks/top";
        }
      ];
    };
    extraConfig = ''
      exec --no-startup-id gnome-keyring-daemon --start --components=ssh,secrets,pkcs11
      exec --no-startup-id nm-applet
    '';
  };
}
