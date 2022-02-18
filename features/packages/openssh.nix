{ pkgs, ... }:

{
  programs.gnupg = {
    # Enabling the agent requires a system restart.
    agent = {
      enable = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
      # pinentryFlavor = "curses";
    };
  };
  environment.systemPackages = with pkgs; [
    pass
  ];
  services.openssh = {
    enable = true;
  };
}
