{...}:

final: prev:
let
  conf = final.mesh.dotfiles.latte-dock.conf;
in
 {
  latte-dock = prev.latte-dock.overrideAttrs  (finalAttrs: previousAttrs: {
      postInstall = previousAttrs.postInstall + ''

        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Custom.layout.latte
        chmod 444 $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Custom.layout.latte
      '';
  });
}
