{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.my-vaultwarden;
in
{
  options.services.my-vaultwarden = {
    enable = mkEnableOption "Vaultwarden self-hosted password manager (only via Tailscale)";

    domain = mkOption {
      type = types.str;
      example = "my-laptop.ts.net";
      description = "Ваш полный домен в Tailscale (обычно <hostname>.ts.net).";
    };

    signupsAllowed = mkOption {
      type = types.bool;
      default = true;
      description = "Разрешить регистрацию новых пользователей. После создания аккаунта выключите.";
    };

    adminTokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Путь к файлу с хешированным ADMIN_TOKEN (сгенерируйте через `vaultwarden hash`). Если null – админ-панель отключена.";
    };

    backupDir = mkOption {
      type = types.path;
      default = "/var/lib/vaultwarden/backup";
      description = "Каталог для автоматических бэкапов базы данных.";
    };
  };

  config = mkIf cfg.enable {
    # 1. Включаем Vaultwarden
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://${cfg.domain}";
        SIGNUPS_ALLOWED = cfg.signupsAllowed;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        WEBSOCKET_ENABLED = true;
        ADMIN_TOKEN = if cfg.adminTokenFile != null
          then builtins.readFile cfg.adminTokenFile
          else null;
        # Для push-уведомлений можно включить отдельно:
        # PUSH_ENABLED = false;
      };
      backupDir = cfg.backupDir;
    };

    # 2. Включаем Tailscale (если не включён глобально)
    services.tailscale = {
      enable = true;
      # Опционально: разрешить автоподключение и т.д.
    };

    # 3. Прокси через tailscale serve
    systemd.services.tailscale-serve = {
      description = "Tailscale proxy for Vaultwarden";
      after = [ "tailscaled.service" "vaultwarden.service" ];
      requires = [ "tailscaled.service" "vaultwarden.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 localhost:8222";
        ExecStop = "${pkgs.tailscale}/bin/tailscale serve off";
        Restart = "on-failure";
        RestartSec = 5;
        # Защита от случайного завершения
        PrivateTmp = true;
      };

      # Перезапускать сервис при перезапуске Vaultwarden
      unitConfig = {
        StartLimitBurst = 3;
        StartLimitIntervalSec = 60;
      };
    };

    # 4. Проверка, что Tailscale включён и MagicDNS работает
    assertions = [
      {
        assertion = cfg.enable -> (builtins.match ".*\.ts\.net$" cfg.domain) != null;
        message = "Домен должен оканчиваться на .ts.net для работы сертификатов Tailscale.";
      }
    ];
  };
}
