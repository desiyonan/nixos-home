{...}:

final: prev:
rec {
  vscode = prev.vscode-with-extensions.override {
    vscode = prev.vscode;
    vscodeExtensions = with prev.vscode-extensions; [
      bbenoist.nix
      davidanson.vscode-markdownlint
      editorconfig.editorconfig
      ms-vscode-remote.remote-ssh
      ms-ceintl.vscode-language-pack-zh-hans
      vscodevim.vim
      esbenp.prettier-vscode
      vscode-icons-team.vscode-icons

      vue.volar
      ms-python.python
      ms-python.vscode-pylance
      matthewpi.caddyfile-support
      # signageos.signageos-vscode-sops
    ] ++
    prev.vscode-utils.extensionsFromVscodeMarketplace [

    ];
  };
}
