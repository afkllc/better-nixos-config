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
          interval = 1;
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
        "${mod}+d" = "exec --no-startup-id dmenu_run";
        "${mod}+Shift+x" = "exec sh -c 'i3lock -c 222222 & sleep 5 && xset dpms force off'";
        "${mod}+Return" = "exec kitty";
        # Focus
        "${mod}+j" = "focus left";
        "${mod}+k" = "focus down";
        "${mod}+l" = "focus up";
        "${mod}+semicolon" = "focus right";
        # Move
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+l" = "move up";
        "${mod}+Shift+semicolon" = "move right";
        # Workspaces
        "${mod}+1" = "workspace number $ws1";
        "${mod}+2" = "workspace number $ws2";
        "${mod}+3" = "workspace number $ws3";
        "${mod}+4" = "workspace number $ws4";
        "${mod}+5" = "workspace number $ws5";

        "${mod}+Shift+1" = "move container to workspace number $ws1";
        "${mod}+Shift+2" = "move container to workspace number $ws2";
        "${mod}+Shift+3" = "move container to workspace number $ws3";
        "${mod}+Shift+4" = "move container to workspace number $ws4";
        "${mod}+Shift+5" = "move container to workspace number $ws5";
        # Audio
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute 0 toggle";
        # Screen Brightness
        "XF86MonBrightnessUp" = "exec xbacklight -inc 20";
        "XF86MonBrightnessDown" = " exec xbacklight -dec 20";
      };
      bars = [
        {
          position = "top";
          statusCommand = "i3blocks -c $HOME/.config/i3blocks/top";
        }
      ];
    };
    extraConfig = "\nexec --no-startup-id nm-applet\nexec --no-startup-id gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg\n";
  };
}
