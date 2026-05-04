{
  name = "dnf";
  groups = [ "users" "wheel" "networkmanager" "video" "libvirtd" "root" "audio" "docker" "sudo"];
  # linger = true; # keep user services running
  uid = 1000;
}
