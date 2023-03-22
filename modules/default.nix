{ pkgs, ...}:
{
  imports = [
    ./features
    ./nvidia-offload.nix
  ];

  options.systemConfig =  {
  };

}
