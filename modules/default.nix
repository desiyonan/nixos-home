{ pkgs, ...}:
{
  imports = [
    ./nvidia-offload.nix
  ];

  options.systemConfig =  {
  };

}
