{ pkgs, ... }:

{
  imports = [
    ./display.nix
    ./fonts.nix
    ./hardware.nix
    ./im.nix
    ./network.nix
    ./nix-features.nix
    ./passwordstore.nix
    ./shell.nix
    ./zone.nix

    ../packages/vscode.nix
    ../packages/openssh.nix
  ];
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  environment.systemPackages = with pkgs; [
    appimage-run
    appimagekit
    anydesk
    bash
    bind
    direnv
    docker-client
    dhcp
    firefox
    flameshot
    fzf
    gcc
    glibc
    git
    gh
    go
    google-chrome
    gnome.gnome-keyring
    jdk8
    jdk11
    ## 太新了 管的严
    # jetbrains.idea-ultimate
    (jetbrains.idea-ultimate.overrideAttrs ( oldAttrs: rec {
      version = "2020.3";
      name = "idea-ultimate-${version}";
      src = fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-${version}-no-jbr.tar.gz";
        sha256 = "43a10e1be8075ebd07bafcbe65ef431db304ee96c3072ff308e188fb9fdbcbd0";
      };
    }))
    latte-dock
    ntfs3g

    libsForQt5.krdc
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtwayland
    libsForQt5.qtstyleplugins

    htop
    hugo
    nix-index
    netease-cloud-music-gtk
    p7zip
    pciutils
    refind
    tree
    # termius
    #softmaker-office #收费不好用
    unar
    vim
    wget
  ];
}
