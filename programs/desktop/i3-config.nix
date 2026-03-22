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
        volume = {
          interval = 1;
          command = ''echo "Volume: $(pactl list sinks | grep Volume | head -n1 | awk '{print $5}')"'';
        };
        battery = {
          interval = 1;
          command = ''echo "Battery: $(acpi -b | grep -P -o '[0-9]+(?=%)')%"'';
        };
        disk = {
          interval = 1;
          command = ''echo "Disk: $(df -h / | grep / | awk '{print $5}')"'';
        };
        memory = {
          interval = 1;
          command = ''echo "Memory: $(free -h | grep Mem | awk '{print $3}')"'';
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
        "${mod}+Return" = "exec i3-sensible-terminal";
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
        "${mod}+w+1" = "workspace number $ws1";
        "${mod}+w+2" = "workspace number $ws2";
        "${mod}+w+3" = "workspace number $ws3";
        "${mod}+w+4" = "workspace number $ws4";
        "${mod}+w+5" = "workspace number $ws5";

        "${mod}+Shift+w+1" = "move container to workspace number $ws1";
        "${mod}+Shift+w+2" = "move container to workspace number $ws2";
        "${mod}+Shift+w+3" = "move container to workspace number $ws3";
        "${mod}+Shift+w+4" = "move container to workspace number $ws4";
        "${mod}+Shift+w+5" = "move container to workspace number $ws5";
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
    extraConfig = "\n        set $ws1 'Browser'\n\n        set $ws2 'Terminal'\n\n        set $ws3 'Chat'\n\n        set $ws4 '4'\n\n        set $ws5 '5'\n\n        exec --no-startup-id nm-applet\n\n        ";
  };
}