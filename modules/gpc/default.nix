{ pkgs, ...}:
{
  imports = [
    ../features
    ../../services/clash
    ../../services/nvidia-offload
  ];

}
