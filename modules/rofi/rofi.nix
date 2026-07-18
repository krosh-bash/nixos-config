{ config, pkgs, lib, ... }:

with lib;

{
  options.modules.rofi = {
    enable = mkEnableOption "Rofi launcher with dynamic colors";
  };

  config = let
    user = "krosh";
    userHome = config.users.users.${user}.home or "/home/${user}";
    configFile = "${userHome}/.config/rofi/config.rasi";
  in mkIf config.modules.rofi.enable {
    environment.systemPackages = with pkgs; [ rofi jq ];

    system.activationScripts.rofi-setup = {
      text = ''
        mkdir -p "${userHome}/.config/rofi"
        cat > "${configFile}" <<'EOF'
        * {
          font: "JetBrainsMonoNL Nerd Font Propo 12";
          bg: #1e1e2e;
          bg-alt: #44475a;
          fg: #81a2be;
          accent: #81a2be;
          background-color: transparent;
          text-color: @fg;
        }
        configuration {
          show-icons: true;
        }
        window {
          width: 700px;
          height: 600px;
          border: 2px;
          border-color: @accent;
          background-color: rgba(30,30,46,0.5);
        }
        inputbar {
            padding: 12px;
            background-color: @bg-alt;
            children: [ entry ];
        }
        entry {
            placeholder: "Search apps...";
            placeholder-color: grey;
            padding: 6px 10px;
            margin: 0;
            text-color: white;
            vertical-align: 0.5;
        }
        element-icon {
          size: 35px;
        }
        element selected {
            background-color: @bg-alt;
            text-color: rgb(255, 255, 255);
        }
        EOF
        chown "${user}:users" "${configFile}" 2>/dev/null || true
      '';
      deps = [];
    };

    environment.etc."rofi/update-colors.sh" = {
      text = ''
        #!/run/current-system/sw/bin/bash
        colors_json="$HOME/.cache/matugen/colors.json"
        if [ -f "$colors_json" ]; then
          bg=$(jq -r '.background' "$colors_json")
          bg_alt=$(jq -r '.background_alt // .background' "$colors_json")
          fg=$(jq -r '.foreground' "$colors_json")
          accent=$(jq -r '.accent // .foreground' "$colors_json")
          cat > "${userHome}/.config/rofi/config.rasi" <<EOC
        * {
          font: "JetBrainsMonoNL Nerd Font Propo 12";
          bg: $bg;
          bg-alt: $bg_alt;
          fg: $fg;
          accent: $accent;
          background-color: transparent;
          text-color: @fg;
        }
        configuration {
          show-icons: true;
        }
        window {
          width: 700px;
          height: 600px;
          border: 2px;
          border-color: @accent;
          background-color: rgba(30,30,46,0.5);
        }
        inputbar {
            padding: 12px;
            background-color: @bg-alt;
            children: [ entry ];
        }
        entry {
            placeholder: "Search apps...";
            placeholder-color: grey;
            padding: 6px 10px;
            margin: 0;
            text-color: white;
            vertical-align: 0.5;
        }
        element-icon {
          size: 35px;
        }
        element selected {
            background-color: @bg-alt;
            text-color: rgb(255, 255, 255);
        }
        EOC
        else
          echo "No matugen colors found, using fallback" >&2
        fi
      '';
      mode = "0755";
    };
  };
}
