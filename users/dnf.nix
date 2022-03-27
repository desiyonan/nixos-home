{pkgs,...}:

{
  name = "dnf";
  groups = [ "wheel" "networkmanager" "video" "libvirtd" ];
  uid = 1000;
  # shell = pkgs.bash;
}
