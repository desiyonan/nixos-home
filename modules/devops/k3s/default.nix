{ config, lib, ... }:

let
  cfg = config.modules.devops;
in
{
  options.modules.devops.k3s = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "K3s options (enable one role or cluster profile below)";
    };

    legacy.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "K3s 1.24 server (pinned nixpkgs tarball)";
    };

    single.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Single-node K3s server";
    };

    cluster.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "K3s cluster shared containerd/ZFS setup";
    };

    leader.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "K3s cluster init leader";
    };

    server.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "K3s cluster server node";
    };

    agent.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "K3s cluster agent node";
    };
  };

  imports = [
    ./legacy.nix
    ./single.nix
    ./cluster
    ./leader.nix
    ./server.nix
    ./agent.nix
  ];
}
