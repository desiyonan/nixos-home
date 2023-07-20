{ config
, pkgs
,system
, ...
}:

let

  old_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c2c0373ae7abf25b7d69b2df05d3ef8014459ea3.tar.gz";
    sha256 = "19a98q762lx48gxqgp54f5chcbq4cpbq85lcinpd0gh944qindmm";
  }) { inherit system; };
  k3s_1_24 = old_pkgs.k3s;
in
{
  config = {
    services.k3s.enable = true;
    # services.k3s.package = k3s_1_24;
    virtualisation.containerd.enable = true;
    virtualisation.containerd.settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        # FIXME: upstream
        cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
          mkdir -p $out
          ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
        ''}";
      };
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
    ];

    systemd.services.k3s = {
      wants = [ "containerd.service" ];
      after = [ "containerd.service" ];
    };

    systemd.services.containerd.environment = {
      ALL_PROXY = "http://127.0.0.1:7890";
      HTTP_PROXY = "http://127.0.0.1:7890";
      HTTPS_PROXY = "http://127.0.0.1:7890";
    };

    systemd.services.containerd.serviceConfig = {
      ExecStartPre = [
        "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs zroot/containerd"
      ];
    };
  };
}
