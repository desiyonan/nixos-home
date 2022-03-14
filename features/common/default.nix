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
    ark
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
      version = "2021.2";
      name = "idea-ultimate-${version}";
      src = fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-${version}-no-jbr.tar.gz";
        sha256 = "554e0613e69fcb94d899329305df3b8ae0a96604af70ed77034a44e49e0d7d3d";
      };
    }))
    latte-dock
    ## latte-dock设置QT输入法模块后没法点击窗口
    # (pkgs.latte-dock.overrideAttrs (oldAttrs :{
    #   buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.makeWrapper ];
    #   postInstall = oldAttrs.postInstall or "" +''
    #     wrapProgram $out/bin/latte-dock \
    #       --prefix QT_IM_MODULE : "xim"
    #   '';
    # }))
    ntfs3g

    egl-wayland
    libsForQt5.krdc
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtwayland
    libsForQt5.qtstyleplugins

    htop
    hugo
    kate
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
    vivaldi
    vivaldi-ffmpeg-codecs
    wget
    wpsoffice
  ];
}
