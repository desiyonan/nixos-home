{ pkgs, ... }:

{
  # programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
  programs.gnupg = {
    # Enabling the agent requires a system restart.
    agent = {
      enable = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
      enableBrowserSocket = true;
      # pinentryFlavor = "curses";
      settings = {
        default-cache-ttl = 2 * 60 * 60;
      };
    };
  };
  # programs.ssh.startAgent = true;
  environment.systemPackages = with pkgs; [
    # pass
  ];
}
