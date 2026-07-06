{ config, pkg, ... }:
{
	imports = [
		./hardware-configuration.nix
		./users.nix
		./packages.nix
		.services/niri.nix
	];

	boot.loader.sytemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	networking.hostName = "nixos";

	fileSystems = {
	"/" = {
	 options = [ "compress=zstd" ];
	};
	"/home" = {
	 options = [ "compress=zstd" ];
	};	
	"/nix" = { 
	 options = [ "compress=zstd" "noatime" ];
	};
};
	programs.niri.enable = true;

	environment.systemPackages = with pkgs; [
	alacritty
	fuzzel
	waybar
	vim
	git
	firefox
];
	user.user.krosh = {
	 isNormalUser = true;
	 extraGroups = [ "wheel" ];
	};
	services.displayManager.sddm.wayland.enable = true;

	system.stateVersion = "24.11";
}
