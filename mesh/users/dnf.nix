{ ... }@args:
{pkgs,...}:
{
  users.users.dnf = {
    name = "dnf";
    isNormalUser = true;
    isSystemUser = false;
    extraGroups = [
      "users"
      "wheel"
      "networkmanager"
      "video"
      "libvirtd"
      "root"
      "audio"
      "docker"
      "sudo"
    ];
    uid = 1000;
    initialPassword = "password";
  };
}
