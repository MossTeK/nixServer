# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tek =
    {
      isNormalUser = true;
      description = "tek";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ vim ];
    };

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    wget
    neofetch
    git
    lf
    gitlab
    guacamole-server
  ];

  # Enable cron service
  services.cron =
    {
      enable = true;
      systemCronJobs = [
        "0 4 * * * /run/current-system/sw/bin/shutdown -r now"
        "0 3 * * * /home/tek/devel/startup.sh"
      ];
    };

  environment.variables = {};

  # Setup nix trusted users
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable & configure the OpenSSH daemon.
  services.openssh = {
  enable = true;
  # require public key authentication for better security
  settings.PasswordAuthentication = true;
  settings.KbdInteractiveAuthentication = true;
  #settings.PermitRootLogin = "yes";
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}