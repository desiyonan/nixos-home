{ pkgs, ... }:

{
  users.users.dnf = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
}
