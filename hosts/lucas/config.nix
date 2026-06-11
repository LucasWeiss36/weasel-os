{
  pkgs,
  pkgsUnstable,
  inputs,
  lib,
  username,
  ...
}: {
  imports = [
    ../../profiles/system/base.nix
    ./hardware.nix
    ./users.nix
  ];

  features.canbus.enable = true;
  features.displaylink.enable = true;
  local.hardware-clock.enable = true;

  networking = {
    networkmanager.wifi.backend = lib.mkForce "iwd";
    wireless.iwd.enable = lib.mkForce true;
  };

  programs = {
    gnupg.agent.enableSSHSupport = false;
    steam.gamescopeSession.enable = false;
    ssh = {
      startAgent = true;
      extraConfig = ''
        Host *
          AddKeysToAgent yes
      '';
    };
  };

  environment.systemPackages =
    (with pkgs; [
      openssl
      proton-pass
      python3
      python3Packages.pip
      snapper
      btrfs-progs
      nil
      xwayland-satellite
      cava
      cliphist
      helix
      lsfg-vk
      lsfg-vk-ui
      superTuxKart
      bambu-studio
      firefox
      ventoy-full-qt
    ])
    ++ [
      pkgsUnstable.nodejs
    ];

  services = {
    snapper = {
      snapshotInterval = "daily";
      cleanupInterval = "daily";

      configs.home = {
        SUBVOLUME = "/home";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 0;
        TIMELINE_LIMIT_MONTHLY = 0;
        TIMELINE_LIMIT_YEARLY = 0;
        SPACE_LIMIT = "0.3";
      };
    };
    tlp.enable = false;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    gnome.gcr-ssh-agent.enable = false;
    blueman.enable = true;
    udev = {
      packages = [pkgs.sane-airscan];
      extraRules = ''
        ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
        ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';
    };
  };

  hardware = {
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
    "net.bridge.bridge-nf-call-arptables" = 0;
  };
}
