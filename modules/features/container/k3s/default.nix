{ pkgs, mpkgs, modulesPath, system, ... }:

let
  # old_pkgs = import (builtins.fetchGit {
  #        # Descriptive name to make the store path easier to identify                
  #        name = "my-old-revision";                                                 
  #        url = "https://github.com/NixOS/nixpkgs/";                       
  #        ref = "refs/heads/nixos-22.11";
  #        # get version 1.24.4+k3s1
  #        rev = "c2c0373ae7abf25b7d69b2df05d3ef8014459ea3";                                           
  #    }) {}; 
  old_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c2c0373ae7abf25b7d69b2df05d3ef8014459ea3.tar.gz";
    sha256 = "19a98q762lx48gxqgp54f5chcbq4cpbq85lcinpd0gh944qindmm";
  }) { inherit system; };
  k3s_1_24 = old_pkgs.k3s;
in
{
  # imports = [
  # ];
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  # services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
  # ];
  services.k3s.package = k3s_1_24;

  environment.systemPackages =  with pkgs; [
    # k3s
    k3s_1_24
    kube3d
  ];
  # TODO server 分开
  # networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.extraFlags = "--disable traefik --flannel-backend=host-gw --snapshotter=zfs --container-runtime-endpoint unix:///run/containerd/containerd.sock";
}
