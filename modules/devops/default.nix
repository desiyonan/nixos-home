{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;

  devopsEnable = description:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = description;
    };
in
{
  options.modules.devops = {
    enable = lib.mkEnableOption "DevOps tooling (containers, Kubernetes, cloud CLIs, etc.)";

    aliyun.enable = devopsEnable "Alibaba Cloud CLI";
    aws.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "AWS CLI and SAM CLI";
    };

    containerd.enable = devopsEnable "containerd runtime and nerdctl";
    kubectl.enable = devopsEnable "kubectl";
    etcd.enable = devopsEnable "etcd client";
    helm.enable = devopsEnable "Helm";
    virtualbox.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "VirtualBox host support";
    };
    k8s.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Kubernetes CLI tools (kubectl ecosystem extras)";
    };
    waydroid.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Waydroid and LXD";
    };
    rancher.enable = devopsEnable "Rancher CLI";
  };

  imports = lib.listModules ./.;
}
