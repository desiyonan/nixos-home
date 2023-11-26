{ pkgs, mpkgs, modulesPath, ... }:

{

  environment.systemPackages =  with pkgs; [
    docker
    docker-client
    containerd
  ];

  environment = {
    # variables = {
    #   DOCKER_HOST = "dk.dnfn.tech:5732";
    # };
    # sessionVariables = {
    #   DOCKER_HOST = "dk.dnfn.tech:5732";
    # };
  };
}
