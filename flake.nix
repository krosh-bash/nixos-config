{
  description = "Объединённая конфигурация NixOS с портабельным Niri и модульным Waybar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    matugen.url = "github:InioX/matugen"; # <-- Официальный Matugen
    tg-ws-proxy.url = "github:pialtor/tg-ws-proxy-flake";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, matugen, tg-ws-proxy, zen-browser, home-manager, nixvim, ... }:
    let
      system = "x86_64-linux";
      username = "krosh";
      lib = nixpkgs.lib;

      zen-overlay = final: prev: {
        zen-browser = zen-browser.packages.${final.system}.default;
      };

      generateWaybarFiles = dir:
        let
          allFiles = lib.filesystem.listFilesRecursive dir;
          toWaybarConfig = path: {
            name = "waybar/${lib.path.removePrefix ./modules/waybar path}";
            value = { source = path; };
          };
        in
          builtins.listToAttrs (map toWaybarConfig allFiles);

      mkHost = hostname: extraSystemModules: extraHomeModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit tg-ws-proxy;
            hostName = hostname;
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
                # Пробрасываем matugen, чтобы взять пакет matugen.packages.''${system}.default
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
    in {
      nixosConfigurations = {
        krosh = mkHost "krosh" [ ] [ ];
      };
      packages.${system} = {
        tg-ws-proxy = tg-ws-proxy.packages.${system}.default;
        zen-browser = zen-browser.packages.${system}.default;
      };
      apps.${system}.tg-ws-proxy = tg-ws-proxy.apps.${system}.default;
    };
}

