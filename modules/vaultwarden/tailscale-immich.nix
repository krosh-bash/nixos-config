{config, pkgs, ... }:
{
users.users.immich = {
  isSystemUser = true;
  extraGroups = [ "users" ];   # <-- добавляем пользователя в группу users
};
services.immich = {
    enable = true;
    port = 2283;               # Порт, на котором будет работать сервер
    host = "0.0.0.0";          # Разрешаем подключения с других устройств в сети[reference:2][reference:3]
    openFirewall = true;       # Автоматически открываем порт в брандмауэре[reference:4][reference:5]
  };

users.users.krosh.homeMode = "750";
services.tailscale.enable = true;
services.navidrome.openFirewall = true;

services.navidrome = {
  enable = true;
 plugins = with pkgs.navidromePlugins; [
      apple-music  # <-- Добавляем плагин сюда
    ];
 settings = {
    MusicFolder = "/Music/yandex/ilyas";
    Address = "0.0.0.0";
    LyricsPriority = "lrc,embedded,plugin";
    CoverArtPriority = "embedded,cover.*,folder.*";
    Plugins.Enabled = true;
    Agents = "lastfm,apple-music,deezer";   # ← агенты метаданных
    LogLevel = "debug";                     # ← уровень логирования
    Plugins.LogLevel = "debug";
    PluginsPath = "/var/lib/navidrome/plugins";
  };
  # Никакого environment здесь!
};
 systemd.tmpfiles.rules = [
  "d /var/lib/navidrome/plugins 0750 navidrome navidrome -"
];
# Даём пользователю krosh право выполнять tailscale file get без пароля
# Даём пользователю krosh право выполнять tailscale file get без пароля
security.sudo.extraRules = [
  {
    users = [ "krosh" ];
    commands = [
      {
        command = "${pkgs.tailscale}/bin/tailscale file get *";
        options = [ "NOPASSWD" ];
      }
    ];
  }
];

# Создаём папку для входящих файлов

# Пользовательский сервис
systemd.user.services.tailreceive = {
  description = "Receive Taildrop files";
  after = [ "network.target" ];
  wantedBy = [ "default.target" ];
  serviceConfig = {
    ExecStart = "/run/wrappers/bin/sudo ${pkgs.tailscale}/bin/tailscale file get --loop --verbose /home/krosh/Загрузки/Tailscale";
    Restart = "always";
    RestartSec = 10;
  };
};
}
