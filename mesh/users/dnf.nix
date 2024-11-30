{
  name = "dnf";
  groups = [ "users" "wheel" "networkmanager" "video" "libvirtd" "root" "audio"];
  # linger = true; # keep user services running
  uid = 1000;
  # shell = pkgs.bash;
}
