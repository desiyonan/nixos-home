{ pkgs, ...}:
{
  imports = [
    ./clash
    ./dockerd
    ./nvidia-offload
  ];
}
