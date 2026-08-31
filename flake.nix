{
  description = "Объединённая конфигурация NixOS с портабельным Niri, модульным Waybar и окружением для разработки на Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    matugen.url = "github:InioX/matugen";
    tg-ws-proxy.url = "github:pialtor/tg-ws-proxy-flake";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
    zapret-rust.url = "github:Sergeydigl3/zapret-discord-youtube-rust";
     # Добавляем вход noctalia
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";   # использует ваш nixpkgs
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      # Удалена строка flake-utils.follows = "";
    };
  };

  outputs = { self, nixpkgs, matugen, tg-ws-proxy, zen-browser, home-manager, nixvim, rust-overlay, noctalia, nixos-grub-themes, zapret-rust, ... }:
    let
      system = "x86_64-linux";
      username = "krosh";
      lib = nixpkgs.lib;

      # ← ВСЕ ВХОДЫ СОБИРАЕМ В ОДИН АТРИБУТ
      allInputs = {
        inherit nixpkgs matugen tg-ws-proxy zen-browser home-manager nixvim rust-overlay noctalia nixos-grub-themes;
      };

      # Оверлей для Zen Browser
      zen-overlay = final: prev: {
        zen-browser = zen-browser.packages.${final.system}.default;
      };

      # Функция генерации файлов Waybar
      generateWaybarFiles = dir:
        let
          allFiles = lib.filesystem.listFilesRecursive dir;
          toWaybarConfig = path: {
            name = "waybar/${lib.path.removePrefix ./modules/waybar path}";
            value = { source = path; };
          };
        in
          builtins.listToAttrs (map toWaybarConfig allFiles);

      # Функция создания конфигурации NixOS
      mkHost = hostname: extraSystemModules: extraHomeModules: inputs:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit tg-ws-proxy;
            hostName = hostname;
            zapret-rust = zapret-rust;
          };
          modules = [
            { nixpkgs.overlays = [ zen-overlay ]; }
            ./configuration.nix
            nixvim.nixosModules.nixvim
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit hostname matugen; };
                users.${username} = {
                  imports = [
                    ./modules/niri/common.nix
                    ./home.nix
                  ] ++ extraHomeModules;
                  xdg.configFile = generateWaybarFiles ./modules/waybar;
                };
              };
            }
          ] ++ extraSystemModules;
        };

      # Сборка pkgs для devShell с rust-overlay
      rustOverlay = import rust-overlay;
      pkgsDev = import nixpkgs {
        inherit system;
        overlays = [ rustOverlay ];
      };
      rust-toolchain = pkgsDev.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
      };

    in {
      # Конфигурации NixOS
      nixosConfigurations = {
        krosh = mkHost "krosh" [ ] [ ] allInputs;   # ← теперь передаём allInputs
      };

      # Пакеты и приложения
      packages.${system} = {
        tg-ws-proxy = tg-ws-proxy.packages.${system}.default;
        zen-browser = zen-browser.packages.${system}.default;
      };
      apps.${system}.tg-ws-proxy = tg-ws-proxy.apps.${system}.default;

      # Окружение для разработки на Rust
      devShells.${system}.default = pkgsDev.mkShell {
        buildInputs = with pkgsDev; [
          rust-toolchain
          rust-analyzer
          rustfmt
          clippy
          lld
        ];

        RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
      };
    };
}
