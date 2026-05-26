{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;

  old_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c2c0373ae7abf25b7d69b2df05d3ef8014459ea3.tar.gz";
    sha256 = "19a98q762lx48gxqgp54f5chcbq4cpbq85lcinpd0gh944qindmm";
  }) {
    system = pkgs.stdenv.hostPlatform.system;
  };
  k3s_1_24 = old_pkgs.k3s;
in
{
  config = lib.mkIf (cfg.enable && cfg.k3s.enable && cfg.k3s.legacy.enable) {
    networking.firewall.allowedTCPPorts = [ 6443 ];

    services.k3s = {
      enable = true;
      role = "server";
      package = k3s_1_24;
      extraFlags = lib.concatStringsSep " " [
        "--disable traefik"
        "--flannel-backend=host-gw"
        "--snapshotter=zfs"
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      ];
    };

    environment.systemPackages = [
      k3s_1_24
      pkgs.kube3d
    ];
  };
}
