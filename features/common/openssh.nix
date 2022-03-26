{ pkgs, ... }:

{
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
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
