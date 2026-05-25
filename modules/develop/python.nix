{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.python.enable) {
    environment.systemPackages = with pkgs; [
      python3
      uv
      conda
      micromamba
      python312Packages.huggingface-hub
      jetbrains.pycharm
      ruff
      black
    ];

    environment.variables = {
      HF_ENDPOINT = "https://hf-mirror.com";
      HF_HOME = "/data/workspace/huggingface/";
      MAMBA_ROOT_PREFIX = "/data/workspace/mamba";
      MAMBARC = "/data/workspace/mamba/mambarc.yml";
    };
    environment.sessionVariables = {
      HF_ENDPOINT = "https://hf-mirror.com";
      HF_HOME = "/data/workspace/huggingface/";
      MAMBA_ROOT_PREFIX = "/data/workspace/mamba";
      MAMBARC = "/data/workspace/mamba/mambarc.yml";
    };
  };
}
