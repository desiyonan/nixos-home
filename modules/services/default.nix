{mlib, ...}:
{
  # imports =  mlib.listModules ./.;
  imports = [
    ./clash
    ./dockerd
    ./nvidia-sync
  ] ;
}
