{ pkgs,  ... }:

{

  environment.systemPackages = with pkgs;[
    go
    golangci-lint
    jetbrains.goland
  ];

  environment = {
    # variables = {
    #   GOPATH = "/data/workspace/deps/go";
    # };
    # sessionVariables = {
    #   GOPATH = "/data/workspace/deps/go";
    # };
  };
}
