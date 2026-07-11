{ config, pkgs, ... }:

{
  systemd.services.sync-obsidian-readme = {
    description = "Постоянная синхронизация README.md из Obsidian в /etc/nixos";
    
    wantedBy = [ "multi-user.target" ]; 
    
    path = [ pkgs.inotify-tools pkgs.coreutils ];

    script = ''
      WATCH_DIR="/home/krosh/Document/obsidian"
      FILE_NAME="README.md"
      TARGET_DIR="/etc/nixos"

      while inotifywait -e modify,create "$WATCH_DIR/$FILE_NAME"; do
        cp "$WATCH_DIR/$FILE_NAME" "$TARGET_DIR/$FILE_NAME"
      done
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
      User = "root";
    };
  };
}

