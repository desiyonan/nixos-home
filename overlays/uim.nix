# https://github.com/uim/uim/issues/207
# Cursor/JACK 等注入的 LD_LIBRARY_PATH 会使 uim_init → make_loaded_str SIGSEGV
{ ... }:

final: prev: {
  uim = prev.symlinkJoin {
    name = "uim-safe";
    paths = [ prev.uim ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      for b in \
        uim-fep \
        uim-pref-gtk uim-pref-gtk3 \
        uim-xim \
        uim-toolbar-gtk uim-toolbar-gtk3 \
        uim-toolbar-gtk-systray uim-toolbar-gtk3-systray \
        uim-im-switcher-gtk uim-im-switcher-gtk3 \
        uim-sh
      do
        if [ -x "$out/bin/$b" ]; then
          wrapProgram "$out/bin/$b" \
            --unset LD_LIBRARY_PATH \
            --set-default UIM_FEP py
        fi
      done
    '';
  };
}
